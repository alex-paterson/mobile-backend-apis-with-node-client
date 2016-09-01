//
//  ViewController.swift
//  TodoList
//
//  Created by Alex Paterson on 6/06/2016.
//  Copyright © 2016 Alexander Paterson. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!

    @IBAction func signInButtonPress(sender: AnyObject) {
        let loader = SwiftLoading()
        loader.showLoading()
        if let email = emailTextField.text, let password = passwordTextField.text {
            User.signIn(email, password: password, completionHandler: { (success) in
                if (success) {
                    self.navigationController?.performSegueWithIdentifier("showTodosViewController", sender: nil)
                } else {
                    print("Sign up failed")
                }
                loader.hideLoading()
            })
        }
    }
    
    @IBAction func signUpButtonPress(sender: AnyObject) {
        let loader = SwiftLoading()
        loader.showLoading()
        if let email = emailTextField.text, let password = passwordTextField.text {
            User.create(email, password: password, completionHandler: { (success) in
                if (success) {
                    self.navigationController?.performSegueWithIdentifier("showTodosViewController", sender: nil)
                } else {
                    print("Sign up failed")
                }
                loader.hideLoading()
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true;
    }
}

