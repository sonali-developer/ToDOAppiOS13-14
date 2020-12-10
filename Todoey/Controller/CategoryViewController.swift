//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Sonali Patel on 12/8/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoryArray = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Marker Felt", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor.white]
        print(context)
        self.loadCategories()
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") {
            cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
            cell.textLabel?.font = UIFont(name: "Marker Felt", size: 15.0)
            cell.textLabel?.numberOfLines = 0
            
            let category = self.categoryArray[indexPath.row]
            cell.textLabel?.text = category.name
            return cell
        } else {
            print("Problem dequeuing cell")
            return UITableViewCell()
        }
        
    }
    
    // MARK : - Data Manipulation Methods
    
    func saveCategory() {
        do {
            try self.context.save()
        } catch {
            print("Problem saving categories \(error)")
        }
    }
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        print("Inside Load Categories")
        do {
                self.categoryArray = try self.context.fetch(request)
            print(self.categoryArray)
            } catch {
                print("Problem fetching category from Core Data Model, \(error)")
            }
        tableView.reloadData()
    }
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressedFromCategory(_ sender: UIBarButtonItem) {
        var alertTxtField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category of Taskkkyyyysss", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            let category = Category(context: self.context)
            category.name = alertTxtField.text!
            print("\(alertTxtField.text!)")
            self.categoryArray.append(category)
            self.saveCategory()
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new task category"
            if let _ = alertTextField.text {
                alertTxtField = alertTextField
            }
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    //MARK: - UITableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = self.categoryArray[indexPath.row]
        }
    }
}
