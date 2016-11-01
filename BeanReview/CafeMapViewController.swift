//
//  CafeMapViewController.swift
//  BeanReview
//
//  Created by Tim Haynes on 1/11/16.
//  Copyright © 2016 Agon Consulting. All rights reserved.
//

import UIKit
import MapKit
import CloudKit

class CafeMapViewController: UIViewController, MKMapViewDelegate {

    var cafe: CKRecord!
    var cafePlacemark: CLPlacemark!
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Bean Review - Map View"
        mapView.delegate = self                 
        setupMap()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setupMap() {
        let annotation = MKPointAnnotation()
        annotation.title = cafe.object(forKey: "name") as? String
        annotation.subtitle = cafe.object(forKey: "address") as? String
        
        let location = cafePlacemark.location
        annotation.coordinate = location!.coordinate
        self.mapView.showAnnotations([annotation], animated: true)
        self.mapView.selectAnnotation(annotation, animated: true)
    }
    


}
