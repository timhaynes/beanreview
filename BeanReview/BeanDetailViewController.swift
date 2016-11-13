//
//  BeanDetailViewController.swift
//  BeanReview
//
//  Created by Tim Haynes on 12/11/16.
//  Copyright © 2016 Agon Consulting. All rights reserved.
//

import UIKit
import CloudKit

class BeanDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var bean: CKRecord!
    var reviews: [CKRecord] = []
    var relevantReviews: [CKRecord] = []
    var reviewsFiltered: Bool = false
    
    @IBOutlet var beanProducer: UILabel!
    @IBOutlet var beanCountry: UILabel!
    @IBOutlet var beanRating: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.hidesWhenStopped = true
        // TODO - center on screen
        spinner.center = view.center
        tableView.addSubview(spinner)
        spinner.startAnimating()
        
        self.title = bean.object(forKey: "name") as? String
        beanProducer.text = bean.object(forKey: "producer") as? String
        beanCountry.text = bean.object(forKey: "country") as? String
        fetchReviews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchReviews() {
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Review", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false)]
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.queuePriority = .veryHigh
        queryOperation.resultsLimit = 10000
        
        queryOperation.recordFetchedBlock = { (record) -> Void in
            self.reviews.append(record)
        }
        
        queryOperation.queryCompletionBlock = { (cursor, error) -> Void in
            if error != nil {
                print("iCloud download error for reviews - \(error?.localizedDescription)")
                return
            }
            
            print("BeanDetailViewController - reviews iCloud download successful")
            
            for review in self.reviews {
                let reference = review.object(forKey: "bean") as! CKReference
                if reference.recordID.recordName == self.bean.recordID.recordName {
                    if !self.relevantReviews.contains(review) {
                        self.relevantReviews.append(review)
                    }
                }
            }
            
            OperationQueue.main.addOperation {
                self.reviewsFiltered = true
                self.spinner.stopAnimating()
                self.beanRating.text = self.calculateAverage()
                self.tableView.reloadData()
            }
        }
        publicDatabase.add(queryOperation)
        
    }
    
    func calculateAverage() -> String {
        var ratings = [Double]()
        for review in relevantReviews {
            ratings.append(review.object(forKey: "rating") as! Double)
        }
        
        let roundedRating = average(numbers: ratings).roundTo(places: 1)
        return String(roundedRating)
    }
    
    func average(numbers: [Double]) -> Double {
        var total = 0.0
        
        for number in numbers {
            total += Double(number)
        }
        
        let numbersTotal = Double(numbers.count)
        let average = total / numbersTotal
        return average
    }
    
    // MARK: - Table view setup
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if reviewsFiltered {
            return relevantReviews.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if reviewsFiltered {
            let review = relevantReviews[indexPath.row]
            cell.textLabel?.text = review.object(forKey: "title") as? String
            let rating = review.object(forKey: "rating") as? Double
            let roundedRating = rating?.roundTo(places: 2)
            cell.detailTextLabel?.text = String(describing: roundedRating!)
        } else {
            cell.textLabel?.text = "Downloading reviews..."
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
    
    
}

extension Double {
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
