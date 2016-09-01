//
//  TableViewController.swift
//  TodoList
//
//  Created by Alex Paterson on 29/06/2016.
//  Copyright © 2016 Alexander Paterson. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class TableViewController: UITableViewController {

    @IBAction func logoutButtonPress(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("jwtToken")
        defaults.removeObjectForKey("todosDictionary")
        
        self.navigationController!.performSegueWithIdentifier("showLoginViewController", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 68.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.refreshControl?.addTarget(self, action: #selector(TableViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let todoIds = User.todoIds {
            return todoIds.count
        } else {
            return 0
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! TableViewCell

        if let todoData = User.todosDictionary, let todoIds = User.todoIds {
            let id = todoIds[indexPath.row] as! NSString
            if let todoDictionary = todoData[id] {
                cell.label.text = todoDictionary["text"] as? String
                if let url = todoDictionary["imageURL"] as? String {
                    if let url = NSURL(string: url), let data = NSData(contentsOfURL: url), image = UIImage(data: data) {
                        cell.todoImageView.image = image
                    }
                }
            }
        }

        return cell
    }
 
    func handleRefresh(refreshControl: UIRefreshControl) {
        User.refreshTodos { (success) in
            self.tableView.reloadData()
            refreshControl.endRefreshing()
        }
    }
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            handleDeleteTodo(indexPath)
        }
    }
    
    func handleDeleteTodo(indexPath: NSIndexPath) {
        tableView.beginUpdates()
        let loader = SwiftLoading()
        loader.showLoading()
        
        if let todoIds = User.todoIds {
            let todoId = todoIds[indexPath.row] as! String
            User.deleteTodo(todoId, completionHandler: { (success) in
                
                if (success) {
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                } else {
                    print("Couldn't delete todo")
                }
                
                loader.hideLoading()
                self.tableView.endUpdates()
            })
        }
    }

}







