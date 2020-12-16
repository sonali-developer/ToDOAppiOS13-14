//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//


import UIKit
import RealmSwift

class ToDoListViewController: UITableViewController {

    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    var toDoItems : Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory: Category? {
        didSet {
            self.loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print(dataFilePath)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Marker Felt", size: 20)!]
        self.loadItems()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var alertTxtField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item To Do", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let item = Item()
                        item.title = alertTxtField.text!
                        item.dateCreated = Date()
                        currentCategory.items.append(item)
                        self.realm.add(item)
                    }
                } catch {
                    print("Problem saving item to Realm - \(error.localizedDescription)")
                }
            }
            
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new to do item"
            if let _ = alertTextField.text {
                alertTxtField = alertTextField
            }
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Data Manipulation Methods
    
    func loadItems() {
        self.toDoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        self.tableView.reloadData()
    }
}
//MARK: - Tableview Datasource methods

extension ToDoListViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell") {
            cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
            cell.textLabel?.font = UIFont(name: "Marker Felt", size: 15.0)
            cell.textLabel?.numberOfLines = 0
            
            if let item = toDoItems?[indexPath.row] {
                cell.textLabel?.text = item.title
                cell.accessoryType = item.done == true ? .checkmark : .none
            } else {
                cell.textLabel?.text = "No items added"
            }
            return cell
        } else {
            print("Problem dequeuing cell")
            return UITableViewCell()
        }
        
    }
}

//MARK: - Tableview Delegate Methods

extension ToDoListViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = toDoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


// MARK: - UISearchBarDelegate Methods

extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(searchBar.text!)
        toDoItems = toDoItems?.filter("title contains[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
