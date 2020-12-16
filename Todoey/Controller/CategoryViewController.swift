//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Sonali Patel on 12/8/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var categoryArray : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadCategories()
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else { fatalError("Problem grabbing navigation bar from CategoryViewController") }
        
        navBar.backgroundColor = FlatBlueDark()
        navBar.tintColor = ContrastColorOf(FlatBlueDark(), returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(FlatBlueDark(), returnFlat: true), NSAttributedString.Key.font: UIFont(name: "Marker Felt", size: 40)!]
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categoryArray?[indexPath.row] {
            cell.textLabel?.text = category.name
            cell.backgroundColor = UIColor(hexString: category.colorHexValue)
            cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: category.colorHexValue)!, returnFlat: true)
        } else {
            cell.textLabel?.text = "No categories added yet"
            cell.backgroundColor = UIColor.black
        }
      
        return cell
    }
    
    // MARK: - Data Manipulation Methods
    
    func saveCategory(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Problem saving categories \(error)")
        }
    }

    
    func loadCategories() {
        categoryArray = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    // MARK: - Delete Data on Swipe
    
    override func updateModel(indexpath: IndexPath) {
        if let categoryToDelete = self.categoryArray?[indexpath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryToDelete)
                }
            } catch {
                print("Eror updating the Category object at Swipe Action - \(error.localizedDescription)")
            }
        }
        
    }
    
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressedFromCategory(_ sender: UIBarButtonItem) {
        var alertTxtField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category of Taskkkyyyysss", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            let category = Category()
            category.name = alertTxtField.text!
            category.colorHexValue = UIColor.randomFlat().hexValue()
            print("\(alertTxtField.text!)")
            self.saveCategory(category: category)
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
            destinationVC.selectedCategory = self.categoryArray?[indexPath.row]
        }
    }
}
