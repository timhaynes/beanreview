//
//  AddBeanViewController.swift
//  BeanReview
//
//  Created by Tim Haynes on 19/11/16.
//  Copyright © 2016 Agon Consulting. All rights reserved.
//

import UIKit
import CloudKit

class AddBeanViewController: UIViewController {

    @IBOutlet var countryTextField: UITextField!
    @IBOutlet var producerTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(getUserInput))
        self.navigationItem.rightBarButtonItem = saveButton
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getUserInput() {
        let country = countryTextField.text!
        let producer = producerTextField.text!
        let name = nameTextField.text!
        if validateBean(country: country, producer: producer, name: name) {
            let record = CKRecord(recordType: "Bean")
            record.setValue(country, forKey: "country")
            record.setValue(producer, forKey: "producer")
            record.setValue(name, forKey: "name")
            saveToCloud(record: record)
        }
    }
    
    func validateBean(country: String, producer: String, name: String) -> Bool {
        if country == "" {
            showValidationFailAlert(message: "Please enter a valid country.")
            return false
            // TODO validate against country list
        }
        if producer == "" {
            showValidationFailAlert(message: "Please enter a producer.")
            return false
        }
        if name == "" {
            showValidationFailAlert(message: "Please enter the name of the bean.")
            return false
        }
        
        return true
    }
    
    func showValidationFailAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
    
    
    // MARK: - iCloud
    
    func saveToCloud(record: CKRecord) {
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        publicDatabase.save(record, completionHandler: { (record, error) -> Void in
            if error != nil {
                print("Error saving record to cloud: \(error?.localizedDescription)")
            } else {
                print("Bean record saved to iCloud")
                // TODO make return to previous screen (BeansTableViewController)
                self.dismiss(animated: true, completion: nil)
            }
        })
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
