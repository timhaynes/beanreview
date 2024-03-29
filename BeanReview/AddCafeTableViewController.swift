//
//  AddCafeTableViewController.swift
//  BeanReview
//
//  Created by Tim Haynes on 1/11/16.
//  Copyright © 2016 Agon Consulting. All rights reserved.
//

import UIKit
import CloudKit

class AddCafeTableViewController: UITableViewController {

    @IBOutlet var cafeNameTextField: UITextField!
    @IBOutlet var cafeAddressTextField: UITextField!
    @IBOutlet var cafeHoursAddressTextField: UITextField!
    
    @IBAction func clickDone() {
        saveToCloud()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Save
    
    func saveToCloud() {
        if validateInput() {
            let record = CKRecord(recordType: "Cafe")
            record.setValue(cafeNameTextField.text, forKey: "name")
            record.setValue(cafeAddressTextField.text, forKey: "address")
            record.setValue(cafeHoursAddressTextField.text, forKey: "hours")
            
            let publicDatabase = CKContainer.default().publicCloudDatabase
            publicDatabase.save(record, completionHandler: { (record, error) -> Void in
                if error != nil {
                    print("Error saving cafe record to cloud: \(error?.localizedDescription)")
                } else {
                    print("Cafe record saved to iCloud")
                    self.dismiss(animated: true, completion: nil)
                    // TODO - send to actual detail view of newly created cafe
                    // TODO - or when returning, reload cafes so new one is shown
                }
            })
        }
    }
    
    func validateInput() -> Bool {
        if cafeNameTextField.text! == "" || cafeHoursAddressTextField.text! == "" || cafeAddressTextField.text! == "" {
            let alert = UIAlertController(title: "Error", message: "Please complete all fields", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(alertAction)
            present(alert, animated: true)
            print("AddCafeTableViewController - validation failed")
            return false
        } else {
            return true
        }
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
        return 3
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
