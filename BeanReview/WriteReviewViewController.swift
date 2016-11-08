//
//  WriteReviewViewController.swift
//  BeanReview
//
//  Created by Tim Haynes on 8/11/16.
//  Copyright © 2016 Agon Consulting. All rights reserved.
//

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
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
