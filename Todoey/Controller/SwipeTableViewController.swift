//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Sonali Patel on 12/16/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 90
    }
    
// MARK: - UITableView Data Source Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? SwipeTableViewCell {
            cell.textLabel?.font = UIFont(name: "Marker Felt", size: 15.0)
            cell.textLabel?.numberOfLines = 0
            cell.delegate = self
            return cell
        } else {
            print("Problem dequeuing cell")
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexpath) in
            print("Right swipe happened")
            self.updateModel(indexpath: indexpath)
        }
        
        deleteAction.image = UIImage(named: "delete")
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        return options
    }
    
    func updateModel(indexpath: IndexPath) {
        // Update Realm model objects
    }
}

