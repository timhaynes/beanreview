//
//  BeansTableViewController.swift
//  BeanReview
//
//  Created by Tim Haynes on 10/11/16.
//  Copyright © 2016 Agon Consulting. All rights reserved.
//

import UIKit
import CloudKit

class BeansTableViewController: UITableViewController {

    var beanRecords = [CKRecord]()
    var filteredBeanRecords = [CKRecord]()
    let searchController = UISearchController(searchResultsController: nil)
    var downloaded: Bool = false
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        spinner.hidesWhenStopped = true
        spinner.center = view.center
        tableView.addSubview(spinner)
        spinner.startAnimating()
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        tableView.tableHeaderView = searchController.searchBar
        fetchBeans()
        
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.white
        refreshControl?.tintColor = UIColor.gray
        refreshControl?.addTarget(self, action: #selector(fetchBeans), for: UIControlEvents.valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
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

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            return ((bean.object(forKey: "name") as? String)?.lowercased().contains(searchText.lowercased()))! ||
            ((bean.object(forKey: "producer") as? String)?.lowercased().contains(searchText.lowercased()))! ||
            ((bean.object(forKey: "country") as? String)?.lowercased().contains(searchText.lowercased()))!
        }
        tableView.reloadData()
    }
    
    func fetchBeans() {
        beanRecords.removeAll()
        tableView.reloadData()
        
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
            print("bean record ID - \(record.recordID)")
            if !self.beanRecords.contains(record) {
                self.beanRecords.append(record)
            }
        }
        
        queryOperation.queryCompletionBlock = { (cursor, error) -> Void in
            if error != nil {
                print("iCloud download error for beans - \(error?.localizedDescription)")
                let alert = UIAlertController(title: "Error", message: "Could not download beans for iCloud, check your connection", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true)
                return
            }
            
            print("BeansTableViewController - beans iCloud download successful")
            
            OperationQueue.main.addOperation {
                self.downloaded = true
                self.spinner.stopAnimating()
                self.tableView.reloadData()
                if let refreshControl = self.refreshControl {
                    if refreshControl.isRefreshing {
                        refreshControl.endRefreshing()
                    }
                }
            }
        }
        
        publicDatabase.add(queryOperation)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toBeanDetailView" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destination = segue.destination as! BeanDetailViewController
                var bean: CKRecord
                
                if downloaded {
                    if searchController.isActive && searchController.searchBar.text != "" {
                        bean = filteredBeanRecords[indexPath.row]
                    } else {
                        bean = beanRecords[indexPath.row]
                    }
                } else {
                    return
                }
                destination.bean = bean
            }
        }
    }
    


}

extension BeansTableViewController: UISearchBarDelegate {
    
}

extension BeansTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
}
