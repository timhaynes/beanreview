//
//  AddReviewSearchViewController.swift
//  BeanReview
//
//  Created by Tim Haynes on 5/11/16.
//  Copyright © 2016 Agon Consulting. All rights reserved.
//

// TODO - implement cache

import UIKit
import CloudKit

class AddReviewSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var beanRecords = [CKRecord]()
    var filteredBeanRecords = [CKRecord]()
    let searchController = UISearchController(searchResultsController: nil)
    var downloaded: Bool = false
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBAction func beanNotHereClicked() {
        print("button clicked")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.hidesWhenStopped = true
        spinner.center = view.center
        //spinner.activityIndicatorViewStyle = .whiteLarge
        tableView.addSubview(spinner)
        spinner.startAnimating()
        
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        tableView.tableHeaderView = searchController.searchBar
        fetchBeans()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if downloaded {
            if searchController.isActive && searchController.searchBar.text != "" {
                return filteredBeanRecords.count
            } else {
                return beanRecords.count
            }
        } else {
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if downloaded {
            let bean: CKRecord
            if searchController.isActive && searchController.searchBar.text != "" {
                bean = filteredBeanRecords[indexPath.row]
            } else {
                bean = beanRecords[indexPath.row]
            }
            cell.textLabel?.text = bean.object(forKey: "name") as? String
            cell.detailTextLabel?.text = (bean.object(forKey: "producer") as? String)! + " - " + (bean.object(forKey: "country") as? String)!
        } else {
            cell.textLabel?.text = "Downloading.."
            cell.detailTextLabel?.text = "Please wait"
        }
        
        return cell
        
    }
    
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredBeanRecords = beanRecords.filter { bean in
            return ((bean.object(forKey: "name") as? String)?.lowercased().contains(searchText.lowercased()))! || ((bean.object(forKey: "producer") as? String)?.lowercased().contains(searchText.lowercased()))! || ((bean.object(forKey: "country") as? String)?.lowercased().contains(searchText.lowercased()))!
        }
        tableView.reloadData()
    }
    
    func fetchBeans() {
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Bean", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["name", "producer", "country"]
        queryOperation.queuePriority = .veryHigh
        queryOperation.resultsLimit = 1000
        
        queryOperation.recordFetchedBlock = { (record) -> Void in
            
            if !self.beanRecords.contains(record) {
                self.beanRecords.append(record)
            }
            
            
        }
        
        queryOperation.queryCompletionBlock = { (cursor, error) -> Void in
            if error != nil {
                print("iCloud download error for beans - \(error?.localizedDescription)")
                // Send download error alert
                return
            }
            
            print("AddReviewSearchViewControler - beans iCloud download successful")
            
            OperationQueue.main.addOperation {
                self.downloaded = true
                self.spinner.stopAnimating()
                self.tableView.reloadData()
            }
        }
        
        publicDatabase.add(queryOperation)
    }
    
}

extension AddReviewSearchViewController: UISearchBarDelegate {
    
}

extension AddReviewSearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
}



