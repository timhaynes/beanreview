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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = review.object(forKey: "title") as? String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
