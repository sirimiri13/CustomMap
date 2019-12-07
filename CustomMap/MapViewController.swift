//
//  MapViewController.swift
//  CustomMap
//
//  Created by Lam Huong on 12/6/19.
//  Copyright © 2019 Lam Huong. All rights reserved.
//

import UIKit
import MapKit


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
    // search
    var searchController: UISearchController!
    var localSearchRequest: MKLocalSearch.Request!
    var localSearch: MKLocalSearch!
    var localSearchResponse: MKLocalSearch.Response!
    
    var annotation: MKAnnotation!
    var locationManager: CLLocationManager!
   var isCurrentLocation: Bool = false
    
    var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var mapView: MKMapView!

   
    var  currentCoordinate = CLLocationCoordinate2D()
    override func viewDidLoad() {
        super.viewDidLoad()
       
        display(lat: 10.762932, long: 106.682182, title: "University Of Science", subTitle: "227 Đường Nguyễn Văn Cừ, Phường 4, Quận 5, Hồ Chí Minh, Việt Nam")
        display(lat: 10.764090, long: 106.681876, title: "Le Hong Phong High School", subTitle: "235 Đường Nguyễn Văn Cừ, Phường 4, Quận 5, Hồ Chí Minh, Việt Nam")
        display(lat: 10.764337, long: 106.682649, title: "Now Zone", subTitle: "235 Đường Nguyễn Văn Cừ, Phường Nguyễn Cư Trinh, Quận 1, Hồ Chí Minh, Việt Nam")
        //configureLocationServices()
        // button get current location
        let currentLocationButton = UIBarButtonItem(title: "Your Location", style: UIBarButtonItem.Style.plain, target: self, action: #selector(MapViewController.currentLocationButtonAction(_:)))
        self.navigationItem.leftBarButtonItem = currentLocationButton
        
        // search
        let searchButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(MapViewController.searchButtonAction(_:)))
        self.navigationItem.rightBarButtonItem = searchButton
        
        mapView.delegate = self
        
        activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
       // zoomToLastestLocal(with: currentCoordinate)
    
        // Do any additional setup after loading the view.
    }
    
    /*func configureLocationServices(){
        locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        if (status == .notDetermined){
            
            locationManager.requestAlwaysAuthorization()
        }
        else if (status == .authorizedAlways || status == .authorizedWhenInUse ){
           beginLocal(locationManager: locationManager)
        }
            
    }*/
    
    
    @objc func currentLocationButtonAction(_ sender: UIBarButtonItem) {
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
    @objc func searchButtonAction(_ button: UIBarButtonItem) {
    if searchController == nil {
        searchController = UISearchController(searchResultsController: nil)
    }
    searchController.hidesNavigationBarDuringPresentation = false
    self.searchController.searchBar.delegate = self
    present(searchController, animated: true, completion: nil)
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        if self.mapView.annotations.count != 0 {
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }
        
        localSearchRequest = MKLocalSearch.Request()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { [weak self] (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil {
                let alert = UIAlertView(title: nil, message: "Place not found", delegate: self, cancelButtonTitle: "Try again")
                alert.show()
                return
            }
            
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.title = searchBar.text
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
            
            let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
            self!.mapView.centerCoordinate = pointAnnotation.coordinate
            self!.mapView.addAnnotation(pinAnnotationView.annotation!)
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
}

 

    
/*extension MapViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("this status changed")
        if (status == .authorizedAlways || status == .authorizedWhenInUse ){
           beginLocal(locationManager: locationManager)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           print("Fail with error \(error)")
       }
       
       func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            print ("Did get lastest location")
        guard let lastestLocation = locations.first else {return}
        if currentCoordinate != nil{
            zoomToLastestLocal(with: lastestLocation.coordinate)
    }
        //zoomToLastestLocal(with: lastestLocation.coordinate)
        //addAnnotations()
        
        display(lat: 10.764337, long: 106.682649, title: "Now Zone", subTitle: "235 Đường Nguyễn Văn Cừ, Phường Nguyễn Cư Trinh, Quận 1, Hồ Chí Minh, Việt Nam")
        display(lat: 10.762932, long: 106.682182, title: "University Of Science", subTitle: "227 Đường Nguyễn Văn Cừ, Phường 4, Quận 5, Hồ Chí Minh, Việt Nam")
        display(lat: 10.764090, long: 106.681876, title: "Le Hong Phong High School", subTitle: "235 Đường Nguyễn Văn Cừ, Phường 4, Quận 5, Hồ Chí Minh, Việt Nam")
        
        currentCoordinate = lastestLocation.coordinate
    }
}*/


/*extension MapViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("The annotation was selected  \(String(describing: view.annotation?.title))")
    }

}*/
    

extension Annotation{
    var region : MKCoordinateRegion{
    let span = MKCoordinateSpan(latitudeDelta: 10.7628, longitudeDelta: 106.6683)
        return MKCoordinateRegion(center: coordinate, span: span)
    }
}
