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
    @IBOutlet var cafePicker: UIPickerView!
    @IBOutlet var ratingPicker: UIPickerView!
    @IBOutlet var titleField: UITextField!
    @IBOutlet var contentTextView: UITextView!
    
    var beanPickerData: [String] = [String]()
    var cafePickerData: [String] = [String]()
    var ratingPickerData: [String] = [String]()
    
    var beanSelection = ""
    var cafeSelection = ""
    var ratingSelection = ""
    
    var beanObjects: [CKRecord] = [CKRecord]()
    var beansDic: [String: CKRecord] = [:]
    // the string key in beansDic is the title used in beanPicker, dic is setup during download
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        beanPicker.delegate = self
        beanPicker.dataSource = self
        cafePicker.delegate = self
        cafePicker.dataSource = self
        ratingPicker.delegate = self
        ratingPicker.dataSource = self
        
        
        // set arrays to 'Loading' and then remove and populate with real data from cloud
        beanPickerData = ["Loading...."]
        cafePickerData = ["Select cafe", "Cafe 3", "Cafe 5", "Cafe 11"]
        ratingPickerData = ["Rating out of 5", "1", "2", "3", "4", "5"]
        
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
        queryOperation.recordFetchedBlock = { (record) -> Void in
            self.beanPickerData.removeAll()
            let name = record.object(forKey: "name") as! String
            let producer = record.object(forKey: "producer") as! String
            let country = record.object(forKey: "country") as! String
            let nameForPicker = name + " " + producer + " " + country
            self.beanPickerData.append(nameForPicker)
            self.beanObjects.append(record)
            self.beansDic[nameForPicker] = record
        }
        
        queryOperation.queryCompletionBlock = { (cursor, error) -> Void in
            if error != nil {
                print("iCloud download error for beans - \(error?.localizedDescription)")
                // send alert
                return
            }
            
            print("AddReviewViewController - beans iCloud download successful")
            OperationQueue.main.addOperation {
                self.beanPicker.reloadAllComponents()
            }
            
        }
        
        publicDatabase.add(queryOperation)
        
    }
    
    func sendToCloud() {
        print("Bean is \(beanSelection)")
        print("Cafe is \(cafeSelection)")
        print("Rating is \(ratingSelection)")
        print("Title of review is \(titleField.text)")
        print("Content of review is \(contentTextView.text)")
        print("\(beansDic)")
    }
    
    
    // Process picker selections
    
    func processPickerSelection(picker: UIPickerView, row: Int, component: Int) {
        switch picker {
        case beanPicker:
            beanSelection = beanPickerData[row]
            print("\(beanSelection)")
        case cafePicker:
            cafeSelection = cafePickerData[row]
        case ratingPicker:
            ratingSelection = ratingPickerData[row]
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
        case cafePicker:
            return cafePickerData[row]
        case ratingPicker:
            return ratingPickerData[row]
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case beanPicker:
            return beanPickerData.count
        case cafePicker:
            return cafePickerData.count
        case ratingPicker:
            return ratingPickerData.count
        default:
            return 1
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView {
        case beanPicker:
            return 1
        case cafePicker:
            return 1
        case ratingPicker:
            return 1
        default:
            return 1
        }
    }



}
