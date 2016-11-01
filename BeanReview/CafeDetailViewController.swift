//
//  CafeDetailViewController.swift
//  BeanReview
//
//  Created by Tim Haynes on 30/10/16.
//  Copyright © 2016 Agon Consulting. All rights reserved.
//

import UIKit
import CloudKit
import MapKit

class CafeDetailViewController: UIViewController {
    
    var cafe: CKRecord?
    var cafePlacemark: CLPlacemark?
    var cafeRecord: CKRecordID!
    var cafeName: String!
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadRecord()
        self.title = cafeName
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showMap))
        mapView.addGestureRecognizer(gestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            
        }
        publicDatabase.add(operation)
    }
    
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
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
