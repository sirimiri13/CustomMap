//
//  MapViewController.swift
//  CustomMap
//
//  Created by Lam Huong on 12/6/19.
//  Copyright © 2019 Lam Huong. All rights reserved.
//

import UIKit
import MapKit


var listLocation : [String] = []
var filterSearchBar = [String]()
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
//        display(lat: 10.762932, long: 106.682182, title: "University Of Science", subTitle: "227 Đường Nguyễn Văn Cừ, Phường 4, Quận 5, Hồ Chí Minh, Việt Nam")
//        display(lat: 10.764090, long: 106.681876, title: "Le Hong Phong High School", subTitle: "235 Đường Nguyễn Văn Cừ, Phường 4, Quận 5, Hồ Chí Minh, Việt Nam")
//        display(lat: 10.764337, long: 106.682649, title: "Now Zone", subTitle: "235 Đường Nguyễn Văn Cừ, Phường Nguyễn Cư Trinh, Quận 1, Hồ Chí Minh, Việt Nam")
    
        // button get current location
        let currentLocationButton = UIBarButtonItem(title: "Your Location", style: UIBarButtonItem.Style.plain, target: self, action: #selector(MapViewController.currentLocationButtonAction(_:)))
        self.navigationItem.leftBarButtonItem = currentLocationButton
        
        // search location button
        let searchButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(MapViewController.searchButtonAction(_:)))
        self.navigationItem.rightBarButtonItem = searchButton
        
        mapView.delegate = self
        activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        userCurrentLocation()
    }
    
 
    
    
    //user's current location
   @objc func currentLocationButtonAction(_ sender: UIBarButtonItem) {
       userCurrentLocation()
    }
    
    func userCurrentLocation(){
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
        
    
    // search button
    @objc func searchButtonAction(_ button: UIBarButtonItem) {
        
    let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationTableViewController") as! LocationTableViewController
        searchController?.searchResultsUpdater = locationSearchTable as! UISearchResultsUpdating
       locationSearchTable.mapView = mapView
        searchController = UISearchController(searchResultsController: locationSearchTable.self)
    searchController.hidesNavigationBarDuringPresentation = false
    searchController.searchBar.delegate = self
    present(searchController, animated: true, completion: nil)
    }
    
    
    
    // search location
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //hide bar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        displaySearch(title: searchBar.text ?? "")
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
 
}

extension Annotation{
    var region : MKCoordinateRegion{
    let span = MKCoordinateSpan(latitudeDelta: 10.7628, longitudeDelta: 106.6683)
        return MKCoordinateRegion(center: coordinate, span: span)
    }
}


