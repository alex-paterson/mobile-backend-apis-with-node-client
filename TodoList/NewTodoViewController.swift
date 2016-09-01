//
//  NewTodoViewController.swift
//  TodoList
//
//  Created by Alex Paterson on 29/06/2016.
//  Copyright © 2016 Alexander Paterson. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NewTodoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var newTodoTextField: UITextField!
    
    @IBOutlet weak var imagePreview: UIImageView!
    
    @IBAction func addImageButtonPress(sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func addButtonPress(sender: AnyObject) {
        let loader = SwiftLoading()
        loader.showLoading()
        if let text = newTodoTextField.text {
            User.createTodo(text, image: imagePreview.image, completionHandler: { (success) in
                if (success) {
                    self.navigationController!.performSegueWithIdentifier("showTodosViewController", sender: nil)
                } else {
                    print("Couldn't create todo")
                }
                loader.hideLoading()
            })
        } else {
            print("No text!")
            loader.hideLoading()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePreview.contentMode = .ScaleAspectFit
            imagePreview.image = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
