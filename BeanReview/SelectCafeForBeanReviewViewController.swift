//
//  SelectCafeForBeanReviewViewController.swift
//  BeanReview
//
//  Created by Tim Haynes on 7/11/16.
//  Copyright © 2016 Agon Consulting. All rights reserved.
//

import UIKit
import CloudKit

class SelectCafeForBeanReviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var bean: CKRecord!
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet var tableView: UITableView!
    
    var cafeRecords = [CKRecord]()
    var filteredCafeRecords = [CKRecord]()
    var downloaded: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        tableView.tableHeaderView = searchController.searchBar
        
        self.title = (bean.object(forKey: "name") as? String)! + " review"
        
        fetchCafes()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - iCloud
    
    func fetchCafes() {
        
        
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Cafe", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["name", "address"]
        queryOperation.queuePriority = .veryHigh
        queryOperation.resultsLimit = 1000
        queryOperation.recordFetchedBlock = { (record) -> Void in
            self.cafeRecords.append(record)
        }
        
        queryOperation.queryCompletionBlock = { (cursor, error) -> Void in
            if error != nil {
                //error
                return
            }
            
            print("SelectCafeForBeanReviewViewController - iCloud download successful")
            OperationQueue.main.addOperation {
                self.downloaded = true
                self.tableView.reloadData()
            }
        }
        
        publicDatabase.add(queryOperation)
    }
    

    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if downloaded {
            if searchController.isActive && searchController.searchBar.text != "" {
                return filteredCafeRecords.count
            } else {
                return cafeRecords.count
            }
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if downloaded {
            let cafe: CKRecord
            if searchController.isActive && searchController.searchBar.text != "" {
                cafe = filteredCafeRecords[indexPath.row]
            } else {
                cafe = cafeRecords[indexPath.row]
            }
            cell.textLabel?.text = cafe.object(forKey: "name") as? String
            cell.detailTextLabel?.text = cafe.object(forKey: "address") as? String
        } else {
            cell.textLabel?.text = "Downloading.."
            cell.detailTextLabel?.text = "Please wait"
        }
        
        return cell
        
    }
    
    // MARK: - Search
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredCafeRecords = cafeRecords.filter { cafe in
            return ((cafe.object(forKey: "name") as? String)?.lowercased().contains(searchText.lowercased()))!
        }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            if segue.identifier == "toBeanReview" {
                let destination = segue.destination as! WriteReviewViewController
                var cafe: CKRecord?
                if !searchController.isActive && searchController.searchBar.text == "" {
                    cafe = cafeRecords[indexPath.row]
                } else {
                    cafe = filteredCafeRecords[indexPath.row]
                }
                
                destination.cafe = cafe
                destination.bean = bean
                
            }
        }
        
    }
    
    
   
}

extension SelectCafeForBeanReviewViewController: UISearchBarDelegate {
    
}

extension SelectCafeForBeanReviewViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
       filterContentForSearchText(searchController.searchBar.text!)
    }
    
}
