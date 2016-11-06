//
//  AddReviewViewController.swift
//  BeanReview
//
//  Created by Tim Haynes on 2/11/16.
//  Copyright © 2016 Agon Consulting. All rights reserved.
//

/* TODO
 1. When select contextTextView - delete 'Your review' text
 2. Download cafe , populate arrays
 3. Make beans have multiple components so select a country, then grower, then bean
*/

import UIKit
import CloudKit

class AddReviewViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBAction func saveClicked() {
        sendToCloud()
    }
    
    @IBOutlet var beanPicker: UIPickerView!
    @IBOutlet var growerPicker: UIPickerView!
    @IBOutlet var countryPicker: UIPickerView!

    var beanPickerData: [String] = [String]()
    var growerPickerData: [String] = [String]()
    var countryPickerData: [String] = [String]()
    
    var beanSelection = ""
    var growerSelection = ""
    var countrySelection = ""
    
    var countryGrowerDic: [String: String] = [:]
    var growerBeanDic: [String: String] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        beanPicker.delegate = self
        beanPicker.dataSource = self
        growerPicker.delegate = self
        growerPicker.dataSource = self
        countryPicker.delegate = self
        countryPicker.dataSource = self
        
        beanPickerData = ["Select grower first"]
        growerPickerData = ["Select country first"]
        countryPickerData = ["Loading...."]
        
        fetchBeans()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        countryPickerData.removeAll()
        queryOperation.recordFetchedBlock = { (record) -> Void in
            let name = record.object(forKey: "name") as! String
            let producer = record.object(forKey: "producer") as! String
            let country = record.object(forKey: "country") as! String
            self.countryPickerData.append(country)
            self.countryGrowerDic[country] = producer
            self.growerBeanDic[producer] = name
        }
        
        queryOperation.queryCompletionBlock = { (cursor, error) -> Void in
            if error != nil {
                print("iCloud download error for beans - \(error?.localizedDescription)")
                // send alert
                return
            }
            
            print("AddReviewViewController - beans iCloud download successful")

            OperationQueue.main.addOperation {
                self.countryPicker.reloadAllComponents()
            }
            
        }
        
        publicDatabase.add(queryOperation)
        
    }
    
    func sendToCloud() {
        print("Bean is \(beanSelection)")
        print("Grower is \(growerSelection)")
        print("Country is \(countrySelection)")
    }
    
    
    // Process picker selections
    
    func processPickerSelection(picker: UIPickerView, row: Int, component: Int) {
        switch picker {
        case beanPicker:
            beanSelection = beanPickerData[row]
            
        case growerPicker:
            growerSelection = growerPickerData[row]
            var beans: [String] = [String]()
            for (grower, bean) in growerBeanDic {
                if grower == growerSelection {
                    beans.append(bean)
                }
            }
            beanPickerData.removeAll()
            beanPickerData = beans
            beanPicker.reloadAllComponents()
            // make bean picker view update
            
        case countryPicker:
            countrySelection = countryPickerData[row]
            var growers: [String] = [String]()
            for (country, grower) in countryGrowerDic {
                if country == countrySelection {
                    growers.append(grower)
                }
            }
            growerPickerData.removeAll()
            growerPickerData = growers
            growerPicker.reloadAllComponents()
            
        default:
            break
        }
    }
    
    // MARK: Picker implementation
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        processPickerSelection(picker: pickerView, row: row, component: component)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case beanPicker:
            return beanPickerData[row]
        case growerPicker:
            return growerPickerData[row]
        case countryPicker:
            return countryPickerData[row]
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case beanPicker:
            return beanPickerData.count
        case growerPicker:
            return growerPickerData.count
        case countryPicker:
            return countryPickerData.count
        default:
            return 1
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView {
        case beanPicker:
            return 1
        case growerPicker:
            return 1
        case countryPicker:
            return 1
        default:
            return 1
        }
    }



}
