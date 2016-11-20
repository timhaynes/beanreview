//
//  AddBeanViewController.swift
//  BeanReview
//
//  Created by Tim Haynes on 19/11/16.
//  Copyright © 2016 Agon Consulting. All rights reserved.
//

import UIKit
import CloudKit

class AddBeanViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet var producerTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    // List of coffee producing countries from Wikipedia
    let beanCountries = ["Brazil", "Vietnam", "Colombia", "Indonesia", "Ethiopia", "India", "Mexico", "Guatemala", "Peru", "Honduras",
                         "Uganda", "Ivory Coast", "China", "Costa Rica", "El Salvador", "Nicaragua", "Papua New Guinea", "Ecuador",
                         "Thailand", "Tanzania", "Dominican Republic", "Kenya", "Venezuela", "Cameroon", "Philippines", "Democratic Republic of the Congo", "Burundi", "Madagascar", "Yemen", "Haiti", "Rwanda", "Guinea", "Cuba", "Togo",
                         "Bolivia", "Zambia", "Angola", "Central African Republic", "Panama", "Zimbabwe", "United States", "Nigeria",
                         "Ghana", "Jamaica", "Sri Lanka", "Malawi", "Paraguay", "Sierra Leone", "Australia", "Trinidad and Tobago", "Nepal", "Republic of the Congo", "Equatorial Guinea", "Gabon", "Benin"]
    var autoComplete = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countryTextField.delegate = self
        tableView.delegate = self
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(getUserInput))
        self.navigationItem.rightBarButtonItem = saveButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Country textfield delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let substring = (countryTextField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if substring.characters.first == substring.lowercased().characters.first {
            searchAutoCompleteEntriesWithSubstring(substring: substring.capitalizingFirstLetter())
        } else {
            searchAutoCompleteEntriesWithSubstring(substring: substring)
        }
        
        return true
    }
    
    func searchAutoCompleteEntriesWithSubstring(substring: String) {
        autoComplete.removeAll(keepingCapacity: false)
        
        for key in beanCountries {
            let myString:NSString! = key as NSString
            let substringRange: NSRange! = myString.range(of: substring)
            if (substringRange.location == 0) {
                autoComplete.append(key)
            }
        }
        
        tableView.reloadData()
    }
    
    // MARK: TableView
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        let index = indexPath.row as Int
        cell.textLabel!.text = autoComplete[index]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autoComplete.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        countryTextField.text = selectedCell.textLabel!.text
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
        if country == "" || !beanCountries.contains(country) {
            showValidationFailAlert(message: "Please enter a valid country.")
            return false
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

extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
