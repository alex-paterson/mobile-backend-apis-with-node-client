//
//  User.swift
//  TodoList
//
//  Created by Alex Paterson on 3/07/2016.
//  Copyright © 2016 Alexander Paterson. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class User {
    
    private static var id: String {
        get {
            return NSUserDefaults.standardUserDefaults().valueForKey("userId") as! String
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "userId")
        }
    }
    private static var token: String {
        get {
            return NSUserDefaults.standardUserDefaults().valueForKey("token") as! String
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "token")
        }
    }
    static var todosDictionary: NSDictionary? {
        get {
            return NSUserDefaults.standardUserDefaults().valueForKey("todosDictionary") as? NSDictionary
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "todosDictionary")
        }
    }
    static var todoIds: NSArray? {
        get {
            if let todosDictionary = todosDictionary {
                return todosDictionary.allKeys
            } else {
                return [AnyObject]()
            }
        }
    }
    
    static func create(email: String, password: String, completionHandler: (success: Bool) -> ()) {
        User.postCredentials(APIEndpoints.signupURL, email: email, password: password) { (success) in
            completionHandler(success: success)
        }
    }
    static func signIn(email: String, password: String, completionHandler: (success: Bool) -> ()) {
        User.postCredentials(APIEndpoints.signinURL, email: email, password: password) { (success) in
            completionHandler(success: success)
        }
    }
    
    static func refreshTodos(completionHandler: (success: Bool) -> ()) {
        Alamofire.request(.GET, APIEndpoints.todosURL(User.id), encoding: .JSON, headers: ["authorization": User.token])
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        let todosDictionary = NSMutableDictionary()
                        if let array = json["todos"].arrayObject {
                            for item in array {
                                if let item = item as? NSDictionary {
                                    if let id = item["_id"], text = item["text"] {
                                        if let id = id as? String, text = text as? String {
                                            var dictionaryToStore = [
                                                "text": text
                                            ]
                                            if let imageURL = item["imageURL"], let imURL = imageURL as? String {
                                                dictionaryToStore["imageURL"] = imURL
                                            }
                                            
                                            todosDictionary.setObject(dictionaryToStore, forKey: id)
                                        }
                                    }
                                }
                            }
                        }
                        User.todosDictionary = todosDictionary
                        completionHandler(success: true)
                        return
                    }
                case .Failure (let error):
                    print("ERR \(response) \(error)")
                }
                completionHandler(success: false)
        }
    }
    
    static func deleteTodo(id: String, completionHandler: (success: Bool) -> ()) {
        Alamofire.request(.DELETE, APIEndpoints.todoURL(User.id, todoId: id), encoding: .JSON, headers: ["authorization": User.token])
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let todosDictionary = User.todosDictionary {
                        if let todosDictionary = todosDictionary as? NSMutableDictionary {
                            let todosDictionary = NSMutableDictionary(dictionary: todosDictionary)
                            todosDictionary.removeObjectForKey(id)
                            User.todosDictionary = todosDictionary
                            
                            completionHandler(success: true)
                            return
                        }
                    }
                case .Failure (let error):
                    print("ERR \(response) \(error)")
                }
                completionHandler(success: false)
        }
    }
    
    
    
    
    static func uploadImage(image: UIImage, url: String, completionHandler: (success:Bool) -> ()) {
        if let imageData = UIImageJPEGRepresentation(image, 0.3) {
            let request = Alamofire.upload(.PUT, url, headers: ["Content-Type":"image/jpeg"], data:imageData)
            request.validate()
            request.response { (req, res, json, err) in
                if err != nil {
                    print("ERR \(err)")
                    dispatch_async(dispatch_get_main_queue(), {
                        completionHandler(success:false)
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        completionHandler(success:true)
                    })
                }
            }
        }
    }
    
    static func createTodo(text: String, image: UIImage?, completionHandler: (success: Bool) -> ()) {
        let parameters = [
            "text":text,
            "imagePresent": (image != nil) ? true : false
        ]
        Alamofire.request(.POST, APIEndpoints.todosURL(User.id), parameters: parameters as? [String : AnyObject], encoding: .JSON, headers: ["authorization": User.token])
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        print(json)
                        
                        var todos: NSMutableDictionary
                        if let todosDictionary = User.todosDictionary {
                            todos = NSMutableDictionary(dictionary: todosDictionary)
                        } else {
                            todos = NSMutableDictionary()
                        }
                        
                        if let todoText = json["text"].string, let todoId = json["id"].string {
                            var dictionaryToStore = [
                                "text": todoText
                            ]
                            if let imageURL = json["getURL"].string {
                                dictionaryToStore["imageURL"] = imageURL
                            }
                            todos.setObject(dictionaryToStore, forKey: todoId)
                        }
                        
                        
                        User.todosDictionary = todos
                        
                        if (image == nil) {
                            completionHandler(success: true)
                            return
                        } else {
                            if let postURL = json["postURL"].string {
                                print(postURL)
                                if let image = image {
                                    User.uploadImage(image, url: postURL, completionHandler: completionHandler)
                                }
                            }
                        }
                        
                        
                    }
                case .Failure (let error):
                    print("ERR \(response) \(error)")
                    completionHandler(success: false)
                }
        }
    }
    
    private static func postCredentials(endpoint: String, email: String, password: String, completionHandler: (success: Bool) -> ()) {
        let parameters = [
            "email": email,
            "password": password
        ]
        Alamofire.request(.POST, endpoint, parameters: parameters, encoding: .JSON)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                
                switch response.result {
                case.Success:
                    print(response)
                    if let value = response.result.value {
                        let json = JSON(value)
                        User.id = json["userId"].string!
                        User.token = json["token"].string!
                        
                        let todosDictionary = NSMutableDictionary()
                        if let array = json["todos"].arrayObject {
                            for item in array {
                                if let item = item as? NSDictionary {
                                    if let id = item["_id"], text = item["text"] {
                                        if let id = id as? String, text = text as? String {
                                            todosDictionary.setObject(text, forKey: id)
                                        }
                                    }
                                }
                            }
                        }
                        User.todosDictionary = todosDictionary
                        completionHandler(success: true)
                        return
                    }
                case.Failure(let error):
                    print(error)
                }
                
                completionHandler(success: false)
        }
    }
}