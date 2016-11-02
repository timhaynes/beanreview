//
//  AddReviewViewController.swift
//  BeanReview
//
//  Created by Tim Haynes on 2/11/16.
//  Copyright © 2016 Agon Consulting. All rights reserved.
//

import UIKit

class AddReviewViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var beanPicker: UIPickerView!
    @IBOutlet var cafePicker: UIPickerView!
    @IBOutlet var ratingPicker: UIPickerView!
    @IBOutlet var titleField: UITextField!
    @IBOutlet var contentTextView: UITextView!
    
    var beanPickerData: [String] = [String]()
    var cafePickerData: [String] = [String]()
    var ratingPickerData: [String] = [String]()
    
    var beanSelection: String?
    var cafeSelection: String?
    var ratingSelection: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        beanPicker.delegate = self
        beanPicker.dataSource = self
        cafePicker.delegate = self
        cafePicker.dataSource = self
        ratingPicker.delegate = self
        ratingPicker.dataSource = self
        
        beanPickerData = ["Select bean", "Bean 2", "Bean 3"]
        cafePickerData = ["Select cafe", "Cafe 3", "Cafe 5", "Cafe 11"]
        ratingPickerData = ["Rating out of 5", "1", "2", "3", "4", "5"]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Process picker selections
    
    func processBeanSelection(_: Int) {
        
    }
    
    func processCafeSelection(_: Int) {
        
    }
    
    func processRatingSelection(_: Int) {
        
    }
    
    // MARK: Picker implementation
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case beanPicker:
            processBeanSelection(row)
        case cafePicker:
            processCafeSelection(row)
        case ratingPicker:
            processRatingSelection(row)
        default:
            break
        }
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
