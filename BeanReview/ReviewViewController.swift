//
//  ReviewViewController.swift
//  BeanReview
//
//  Created by Tim Haynes on 13/11/16.
//  Copyright © 2016 Agon Consulting. All rights reserved.
//

import UIKit
import CloudKit

class ReviewViewController: UIViewController {
    
    var review: CKRecord!
    var bean: CKRecord!
    var cafe: CKRecord?
    
    @IBOutlet var beanName: UILabel!
    @IBOutlet var cafeName: UILabel!
    @IBOutlet var reviewTitle: UILabel!
    @IBOutlet var reviewBody: UITextView!
    @IBOutlet var cafeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cafeButton.setTitle("", for: .normal)
        cafeName.text = ""
        
        getCafeTitle()
        self.title = "Review"
        beanName.text = bean.object(forKey: "name") as? String
        reviewTitle.text = review.object(forKey: "title") as? String
        reviewBody.text = review.object(forKey: "content") as? String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "reviewToCafe" {
            let destination = segue.destination as? CafeDetailViewController
            destination?.cafeRecord = cafe?.recordID
            destination?.cafeName = cafe?.object(forKey: "name") as? String
        }
    }
    
    
    
    func getCafeTitle() {
        let cafeReference = review.object(forKey: "cafe") as? CKReference
        let cafeRecordID = cafeReference?.recordID
        
        let cloudContainer = CKContainer.default()
        let publicDatabase = cloudContainer.publicCloudDatabase
        
        publicDatabase.fetch(withRecordID: cafeRecordID!) { record, error in
            if error != nil {
                print("ReviewViewController - fetch cafe error - \(error?.localizedDescription)")
                return
            } else {
                self.cafe = record
                OperationQueue.main.addOperation {
                    self.cafeName.text = record!.object(forKey: "name") as? String
                    let buttonTitle = "View " + "\((record!.object(forKey: "name") as? String)!)"
                    self.cafeButton.setTitle(buttonTitle, for: .normal)
                }
            }
        }
    }
    

}
