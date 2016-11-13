//
//  WriteReviewViewController.swift
//  BeanReview
//
//  Created by Tim Haynes on 8/11/16.
//  Copyright © 2016 Agon Consulting. All rights reserved.
//

/* TODO
   1. validation of input
*/

import UIKit
import CloudKit

class WriteReviewViewController: UIViewController {

    var bean: CKRecord!
    var cafe: CKRecord!
    @IBOutlet var reviewTitle: UITextField!
    @IBOutlet var reviewText: UITextView!
    @IBOutlet var ratingSlider: UISlider!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = (bean.object(forKey: "name") as! String) + " @ " + (cafe.object(forKey: "name") as! String)
        
        let saveButton = UIBarButtonItem()
        saveButton.title = "Save"
        saveButton.target = self
        saveButton.action = #selector(saveClicked(sender:))
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    func saveClicked(sender: UIBarButtonItem) {
        print("clicked")
        // validation of input
        saveToCloud()
    }
    
    func saveToCloud() {
        let record = CKRecord(recordType: "Review")
        record.setValue(reviewTitle.text!, forKey: "title")
        record.setValue(reviewText.text!, forKey: "content")
        record.setValue(ratingSlider.value, forKey: "rating")
        
        let beanRef = CKReference(record: bean, action: .none)
        record.setValue(beanRef, forKey: "bean")
        
        let cafeRef = CKReference(record: cafe, action: .none)
        record.setValue(cafeRef, forKey: "cafe")
        
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        publicDatabase.save(record, completionHandler: { (record, error) -> Void in
            if error != nil {
                print("Error \(error?.localizedDescription)")
            }
            
            OperationQueue.main.addOperation {
                self.reviewSavedAlert()
            }
            
        })
        
    }
    
    func reviewSavedAlert() {
        let alert = UIAlertController(title: "Review saved", message: "Thank you for your review!", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { (_) -> Void in
            self.performSegue(withIdentifier: "returnHomeWith", sender: self)
        })
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
