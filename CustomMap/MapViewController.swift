//
//  MapViewController.swift
//  CustomMap
//
//  Created by Lam Huong on 12/6/19.
//  Copyright © 2019 Lam Huong. All rights reserved.
//

import UIKit
import MapKit



var searchController: UISearchController!
var isSearch = false

class Annotation: NSObject, MKAnnotation{
let coordinate: CLLocationCoordinate2D
let title: String?
let subtitle: String?
init(latitude: CLLocationDegrees, longtitue: CLLocationDegrees, title: String?, subtitle: String?){
    self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longtitue)
    self.title = title
    self.subtitle = subtitle
    }
}



class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    // direction
    @IBOutlet weak var getDirectionButton: UIButton!
    var startPointTextField : UITextField?
    var destinationTextField : UITextField?
    var start : String = ""
    var destination: String = ""
    var startLatitude : Double = 0.0
    var startLongtitude : Double = 0.0
    var destinationLatitude : Double = 0.0
    var destinationLongtitude: Double = 0.0
    let sourceAnnotation = MKPointAnnotation()
    let destinationAnnotation = MKPointAnnotation()
    
    // Annotation
    var lat : Double = 0.0
    var long :  Double = 0.0
    var titleAnnotation : String = "abc"
    var subTitleAnnotation : String = ""
    
    // search
 
    var localSearchRequest: MKLocalSearch.Request!
    var localSearch: MKLocalSearch!
    var localSearchResponse: MKLocalSearch.Response!
    
    var annotation: MKAnnotation!
    
    // user's location
    var locationManager: CLLocationManager!
    var isCurrentLocation: Bool = false
    
    
    var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var mapView: MKMapView!

   
  //  var  currentCoordinate = CLLocationCoordinate2D()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // display annotation
        display(lat: 10.762932, long: 106.682182, title: "University Of Science", subTitle: "227 Đường Nguyễn Văn Cừ, Phường 4, Quận 5, Hồ Chí Minh, Việt Nam")
        display(lat: 10.764090, long: 106.681876, title: "Le Hong Phong High School", subTitle: "235 Đường Nguyễn Văn Cừ, Phường 4, Quận 5, Hồ Chí Minh, Việt Nam")
        display(lat: 10.764337, long: 106.682649, title: "Now Zone", subTitle: "235 Đường Nguyễn Văn Cừ, Phường Nguyễn Cư Trinh, Quận 1, Hồ Chí Minh, Việt Nam")
        display(lat: 10.295556, long: 105.766594, title: "My Home", subTitle: "119 Trần Hưng Đạo, SaDec, Đồng Tháp")
        display(lat: 10.288616, long: 105.764067, title: "Bao's Home", subTitle: "324 Trần Hưng Đạo, SaDec, Đồng Tháp")
        // button get current location
        let currentLocationButton = UIBarButtonItem(title: "Your Location", style: UIBarButtonItem.Style.plain, target: self, action: #selector(MapViewController.currentLocationButtonAction(_:)))
        self.navigationItem.leftBarButtonItem = currentLocationButton
        // search location button
//        let searchButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(MapViewController.searchButtonAction(_:)))
//        self.navigationItem.rightBarButtonItem = searchButton
        
        mapView.delegate = self
        activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        userCurrentLocation()
        
        //


        
    }
    
 
    
    
    //user's current location
   @objc func currentLocationButtonAction(_ sender: UIBarButtonItem) {
       userCurrentLocation()
    }
    
    func userCurrentLocation(){
        removeOldDirect()
        if (CLLocationManager.locationServicesEnabled()) {
                   if locationManager == nil {
                       locationManager = CLLocationManager()
                   }
                   locationManager?.requestWhenInUseAuthorization()
                   locationManager.delegate = self
                   locationManager.desiredAccuracy = kCLLocationAccuracyBest
                   locationManager.requestAlwaysAuthorization()
                   locationManager.startUpdatingLocation()
                   isCurrentLocation = true
               }
    }
        
 
  
    
    func display(lat : CLLocationDegrees, long: CLLocationDegrees, title: String? = nil , subTitle: String? = nil){
        let annotation = Annotation(latitude: lat, longtitue: long, title: title, subtitle: subTitle)
            mapView.addAnnotation(annotation)
            //mapView.setRegion(annotation.region, animated: true)
        }
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if !isCurrentLocation {
            return
        }
        
        isCurrentLocation = false
        // get current local
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
       
        
        if self.mapView.annotations.count != 0 {
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }
        
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = location!.coordinate
        pointAnnotation.title = ""
        mapView.addAnnotation(pointAnnotation)
    }
    @IBAction func unwindToMapView(segue: UIStoryboardSegue) {
        if let vc = segue.source as? LocationTableViewController{
            titleAnnotation = vc.selectedLocation
            displaySearch(title: titleAnnotation)
            removeOldDirect()
        }
    }
    func displaySearch(title: String){
        if self.mapView.annotations.count != 0 {
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }
        localSearchRequest = MKLocalSearch.Request()
        localSearchRequest.naturalLanguageQuery = title
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { [weak self] (localSearchResponse, error) -> Void in
            if (error != nil){
                print(error?.localizedDescription)
            }
            else if localSearchResponse?.mapItems.count == 0 {
                    print("Not found")
                }
                else {
                    let pointAnnotation = MKPointAnnotation()
                    pointAnnotation.title = self?.title
                    pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude,longitude: localSearchResponse!.boundingRegion.center.longitude)

                    let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
                    self!.mapView.centerCoordinate = pointAnnotation.coordinate
                    self!.mapView.addAnnotation(pinAnnotationView.annotation!)
                   }
        }
    }
    
    @IBAction func getDirectionTapped(_ sender: Any) {
         let cancelAction = UIAlertAction(title: "Cancel", style:.cancel, handler: nil)
        let alert = UIAlertController(title: "Get Direction", message: "Choose starting point", preferredStyle: .alert)
        let userLocation = UIAlertAction(title: "Your Location", style: .default, handler: self.startUserLocationTapped)
        let anotherLocation = UIAlertAction(title: "Another Location", style: .default, handler: self.anotherLocationTapped)
        alert.addAction(userLocation)
        alert.addAction(anotherLocation)
        alert.addAction(cancelAction)
        self.present(alert, animated: false)
    }
    
    func startUserLocationTapped(alert: UIAlertAction){
        let cancelAction = UIAlertAction(title: "Cancel", style:.cancel, handler: nil)
        let get = UIAlertAction(title: "Go", style: .default, handler: self.getDirectionFromUserLocation)
        let alert = UIAlertController(title: "Get Direction", message: "Start from your position", preferredStyle: .alert)
        alert.addTextField { (destinationTextField) in
            self.destinationPoint(textField: destinationTextField)
        }
        alert.addAction(cancelAction)
        alert.addAction(get)
        self.present(alert, animated: false)
        
    }
    func anotherLocationTapped(alert: UIAlertAction){
        let cancelAction = UIAlertAction(title: "Cancel", style:.cancel, handler: nil)
        let get = UIAlertAction(title: "Go", style: .default, handler: self.getDirecttionFromAnotherPoint)
        let alert = UIAlertController(title: "Get Direction", message:"", preferredStyle: .alert)
        alert.addTextField { (startPointTextField) in
            self.startPoint(textField: startPointTextField)
        }
        alert.addTextField { (destinationTextField) in
            self.destinationPoint(textField: destinationTextField)
        }
        alert.addAction(cancelAction)
        alert.addAction(get)
        self.present(alert, animated: false)
    }
    func startPoint(textField: UITextField!){
        startPointTextField = textField
        startPointTextField?.placeholder = "Choose starting pointing..."
        
    }
    
    func destinationPoint(textField: UITextField!){
      destinationTextField = textField
       destinationTextField?.placeholder = "Choose destination..."
        
    }
    func getDirectionFromUserLocation(alert: UIAlertAction!){
        alert.isEnabled = true
       if (CLLocationManager.locationServicesEnabled()) {
           if locationManager == nil {
               locationManager = CLLocationManager()
           }
           locationManager?.requestWhenInUseAuthorization()
           locationManager.delegate = self
         //  locationManager.desiredAccuracy = kCLLocationAccuracyBest
           locationManager.requestAlwaysAuthorization()
           locationManager.startUpdatingLocation()
           //isCurrentLocation = true
       }
        startLatitude = (locationManager.location as AnyObject).coordinate.latitude
        startLongtitude = (locationManager.location?.coordinate.longitude)!
        
        localSearchRequest = MKLocalSearch.Request()
        let search = destinationTextField?.text
        localSearchRequest.naturalLanguageQuery = search
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { [weak self] (localSearchResponse, error) -> Void in
            if (error != nil){
                print(error?.localizedDescription as Any)
            }
            else if localSearchResponse?.mapItems.count == 0 {
                    print("Not found")
                }
                else {
                self!.destinationLatitude = (localSearchResponse?.boundingRegion.center.latitude)!
                self!.destinationLongtitude = (localSearchResponse?.boundingRegion.center.longitude)!
                self!.removeOldDirect()
                self!.getDirect(sourcelat: self!.startLatitude, sourcelong: self!.startLongtitude, destinationlat: self!.destinationLatitude, destinationlong: self!.destinationLongtitude)
                }
            }
        }
    
    func getDirecttionFromAnotherPoint(alert: UIAlertAction){
        
        localSearchRequest = MKLocalSearch.Request()
        var search = startPointTextField!.text
        localSearchRequest.naturalLanguageQuery = search
               localSearch = MKLocalSearch(request: localSearchRequest)
               localSearch.start { [weak self] (localSearchResponse, error) -> Void in
                   if (error != nil){
                       print(error?.localizedDescription as Any)
                   }
                   else if localSearchResponse?.mapItems.count == 0 {
                           print("Not found")
                       }
                       else {
                    self!.startLatitude = (localSearchResponse?.boundingRegion.center.latitude)!
                    self!.startLongtitude = (localSearchResponse?.boundingRegion.center.longitude)!
                    search = self!.destinationTextField!.text
                    self!.localSearchRequest.naturalLanguageQuery = search
                    self!.localSearch = MKLocalSearch(request: self!.localSearchRequest)
                    self!.localSearch.start { [weak self] (localSearchResponse, error) -> Void in
                                      if (error != nil){
                                          print(error?.localizedDescription as Any)
                                      }
                                      else if localSearchResponse?.mapItems.count == 0 {
                                              print("Not found")
                                          }
                                          else {
                                           self!.destinationLatitude = (localSearchResponse?.boundingRegion.center.latitude)!
                                           self!.destinationLongtitude = (localSearchResponse?.boundingRegion.center.longitude)!
                                            self!.removeOldDirect()
                                           self!.getDirect(sourcelat: self!.startLatitude, sourcelong: self!.startLongtitude, destinationlat: self!.destinationLatitude, destinationlong: self!.destinationLongtitude)
                                   }
                           }
                          
                }
        }

        
    }
    
    func getDirect(sourcelat: Double, sourcelong: Double, destinationlat: Double, destinationlong: Double){
      
        let sourceLocation = CLLocationCoordinate2D(latitude: sourcelat, longitude: sourcelong)
        let destinationLocation = CLLocationCoordinate2D(latitude: destinationlat, longitude: destinationlong)
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
               let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
       // let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "Starting point"
        if let location = sourcePlacemark.location{
            sourceAnnotation.coordinate = location.coordinate
        }
        //let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.title = "Destination point"
        if let location = destinationPlacemark.location{
            destinationAnnotation.coordinate = location.coordinate
        }
        
         self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
           
            let route = response.routes[0]
            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    func removeOldDirect(){
        mapView.overlays.forEach {
              if ($0 is MKPolyline) {
                  self.mapView.removeOverlay($0)
                   }
               }
        mapView.removeAnnotation(sourceAnnotation)
        mapView.removeAnnotation(destinationAnnotation)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
       
            let polyLineRender = MKPolylineRenderer(overlay: overlay)
            polyLineRender.strokeColor = UIColor.blue
            polyLineRender.lineWidth = 4
            return polyLineRender
    }
  
}

