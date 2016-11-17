//
//  CafeDetailViewController.swift
//  BeanReview
//
//  Created by Tim Haynes on 30/10/16.
//  Copyright © 2016 Agon Consulting. All rights reserved.
//

/* TODO 
   1. fix cells - should show bean name and rating  -- get beanName to work
   2. build logic for showing cafes that don't have any reviews
   3. sort reviews by date created (newest at top)
*/

import UIKit
import CloudKit
import MapKit

class CafeDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var cafe: CKRecord?
    var cafePlacemark: CLPlacemark?
    var cafeRecord: CKRecordID!
    var cafeName: String!
    var reviews = [CKRecord]()
    var reviewsDownloaded: Bool = false
    
    var reviewBeanNameDic: [CKRecord:String] = [:]
    var reviewBeanRecordIDDic: [CKRecord:CKRecordID] = [:]
    var beanRecordIDReviewRecord: [CKRecordID:CKRecord] = [:]
    
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadRecord()
        downloadReviews(completionHander: { (reviews) -> Void in
            self.getBeanNames(reviews: reviews)
        })
        self.title = cafeName
    
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showMap))
        mapView.addGestureRecognizer(gestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if reviewsDownloaded {
            return reviews.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if reviewsDownloaded {
            let review = reviews[indexPath.row]
            cell.textLabel?.text = reviewBeanNameDic[review]
        } else {
            cell.textLabel?.text = "Reviews downloading"
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: iCloud
    
    func getBeanNames(reviews: [CKRecord]) {
        
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.publicCloudDatabase
        
        var beanRecords = [CKRecordID]()
        
        
        for review in reviews {
            let beanRef = review.object(forKey: "bean") as! CKReference
            let beanRecord = beanRef.recordID
            beanRecords.append(beanRecord)
            beanRecordIDReviewRecord[beanRecord] = review
            reviewBeanRecordIDDic[review] = beanRecord
        }
        
        for beanRecord in beanRecords {
            let operation = CKFetchRecordsOperation(recordIDs: [beanRecord])
            operation.queuePriority = .veryHigh
            
            operation.fetchRecordsCompletionBlock = { records, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                
                let bean = records?[beanRecord]
                let review = self.beanRecordIDReviewRecord[(bean?.recordID)!]
                self.reviewBeanNameDic[review!] = bean?.object(forKey: "name") as? String
                print(" getBeanNames ---- reviewBeanNameDic = \(review!)")
                print(" getBeanNames ----- \(bean?.object(forKey: "name") as? String)")
                print(" ZZZZZ - \(self.reviewBeanNameDic)")
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                }
                
                
            }
            publicDatabase.add(operation)
        }
        
    }
    

    func downloadReviews(completionHander: @escaping ([CKRecord]) -> Void) {
    
        print("download reviews start")
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.publicCloudDatabase
        
        let reference = CKReference(recordID: cafeRecord, action: .none)
        let predicate = NSPredicate(format: "cafe == %@", reference)
        let query = CKQuery(recordType: "Review", predicate: predicate)
        // TODO sort by date
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.queuePriority = .veryHigh
        queryOperation.resultsLimit = 100
        queryOperation.recordFetchedBlock = { (record) -> Void in
            print(" appending - \(record.object(forKey: "title") as? String)")
            self.reviews.append(record)
            
        }
   
        queryOperation.queryCompletionBlock = { (cursor, error) -> Void in
            if error != nil {
                print("iCloud download error - \(error!.localizedDescription)")
                return
            }
            print("CafeDetailViewController - iCloud download successful")
            self.reviewsDownloaded = true
            completionHander(self.reviews)
        }
    
        publicDatabase.add(queryOperation)
    }
    
    

    func downloadRecord() {
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.publicCloudDatabase
        
        let operation = CKFetchRecordsOperation(recordIDs: [cafeRecord])
        operation.queuePriority = .veryHigh
        operation.fetchRecordsCompletionBlock = { records, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            
            self.cafe = records?[self.cafeRecord]
            print("CafeDetailViewController  -  Successful download of record")
            self.setMap(cafe: self.cafe!)
            print("download record finished")
            
        }
        publicDatabase.add(operation)
    }
    
    // MARK: Map
    
    func setMap(cafe: CKRecord) {
        let address = cafe.object(forKey: "address") as? String
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address!, completionHandler: {
            placemarks, error in
            if error != nil {
                print("Geocode error: \(error!)")
                return
            }
            
            if let placemarks = placemarks {
                let placemark = placemarks[0]
                self.cafePlacemark = placemarks[0]
                let annotation = MKPointAnnotation()
                
                if let location = placemark.location {
                    annotation.coordinate = location.coordinate
                    self.mapView.addAnnotation(annotation)
                    
                    let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 250, 250)
                    self.mapView.setRegion(region, animated: true)
                }
            }
        })
        
    }
    
    func showMap() {
        performSegue(withIdentifier: "showMap", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap" {
            let destinationController = segue.destination as! CafeMapViewController
            destinationController.cafe = cafe
            destinationController.cafePlacemark = cafePlacemark
        }
    }
    

}
