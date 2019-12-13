//
//  LocationTableViewController.swift
//  CustomMap
//
//  Created by Lam Huong on 12/7/19.
//  Copyright © 2019 Lam Huong. All rights reserved.
//

import UIKit
import MapKit


class LocationTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
   @IBOutlet weak var searchBar: UISearchBar!
    var listLocation : [String] = []
    var filterSearchBar = [String]()
    var selectedLocation: String = ""
    var isSearch : Bool = false
    
   func updateSearchResults(for searchController: UISearchController) {
        filterSearchBar.removeAll(keepingCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (listLocation as NSArray).filtered(using: searchPredicate)
        filterSearchBar = array as! [String]
        

        self.tableView.reloadData()
    }
    
    
   // var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
   

    override func viewDidLoad() {
        super.viewDidLoad()
      /*let nowZone = Location(lat: 10.762932, long: 106.682182, title: "University Of Science", subTitle: "227 Đường Nguyễn Văn Cừ, Phường 4, Quận 5, Hồ Chí Minh, Việt Nam")
      let hcmus = Location(lat: 10.764090, long: 106.681876, title: "Le Hong Phong High School", subTitle: "235 Đường Nguyễn Văn Cừ, Phường 4, Quận 5, Hồ Chí Minh, Việt Nam")
      let lhp = Location(lat: 10.764337, long: 106.682649, title: "Now Zone", subTitle: "235 Đường Nguyễn Văn Cừ, Phường Nguyễn Cư Trinh, Quận 1, Hồ Chí Minh, Việt Nam")*/
    
       listLocation.append("Now Zone")
        listLocation.append("Van Hanh Mall")
        listLocation.append("Tao Dan Park")
        listLocation.append("Nguyen Hue Street")
        listLocation.append("Khoa Hoc Tu Nhien")
        listLocation.append ("Cong Truong Me Linh")
        listLocation.append("Winter Palace")
        listLocation.append("Ba Na Hill")
        listLocation.append("Hung Vuong Plaza")
        tableView.reloadData()
        searchBar.delegate = self

    }
  
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        selectedLocation = searchBar.text!
        performSegue(withIdentifier: "unwindToMapSegue", sender: self)
    }
   
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearch = true;
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearch = false;
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearch = false;
    }

    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        isSearch = false;
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        filterSearchBar = listLocation.filter({ (text) -> Bool in
            let tmp: NSString = text as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        if(filterSearchBar.count == 0){
            isSearch = false;
        } else {
            isSearch = true;
        }
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
       if (isSearch){
            return filterSearchBar.count
        }
        else {
         return listLocation.count
        }
    }
    
  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "cellLocation", for: indexPath)
          if (isSearch){
            cell.textLabel?.text = filterSearchBar[indexPath.row]
            }
        else
        {
            let selectedItem = listLocation[indexPath.row]
            cell.textLabel?.text = selectedItem
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
       let index = indexPath.row
        if(isSearch){
            selectedLocation = filterSearchBar[index]
        }
        else {
            selectedLocation = listLocation[index]
        }
          performSegue(withIdentifier: "unwindToMapSegue", sender: self)

      }
    
    }
  
