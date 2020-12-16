//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//


import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    var toDoItems : Results<Item>?
    let realm = try! Realm()
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory: Category? {
        didSet {
            self.loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadItems()
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let hexColor = selectedCategory?.colorHexValue {
            guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller doesn't exist") }
            
            if let color = UIColor(hexString: hexColor) {
                navBar.backgroundColor = color
                navBar.tintColor = ContrastColorOf(color, returnFlat: true)
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(color, returnFlat: true), NSAttributedString.Key.font: UIFont(name: "Marker Felt", size: 40)!]
                title = selectedCategory!.name
                searchBar.barTintColor = color
            } else {
                
            }
           
        }
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
    
    override func updateModel(indexpath: IndexPath) {
        if let itemToDelete = self.toDoItems?[indexpath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemToDelete)
                }
            } catch {
                print("Eror updating the Item object at Swipe Action - \(error.localizedDescription)")
            }
        }
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
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
            if let item = toDoItems?[indexPath.row] {
                cell.textLabel?.text = item.title
                cell.accessoryType = item.done == true ? .checkmark : .none
                if let color = UIColor(hexString: selectedCategory!.colorHexValue)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(toDoItems!.count)) {
                    cell.backgroundColor = color
                    cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                }
            } else {
                cell.textLabel?.text = "No items added"
                cell.backgroundColor = FlatBlack()
                cell.textLabel?.textColor = FlatWhite()
            }
        
        return cell
        
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
