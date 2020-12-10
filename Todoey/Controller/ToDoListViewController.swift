//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//


import UIKit
import CoreData

class ToDoListViewController: UITableViewController {

    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var itemArray = [Item]()
    
    var selectedCategory: Category? {
        didSet {
            self.loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print(dataFilePath)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Marker Felt", size: 20)!]

        
//        let item1 = Item(context: self.context)
//        item1.title = "1. Visit one Github Swift based project repo and study everything related to it. (Experiment with it)"
//        item1.done = false
//        itemArray.append(item1)
//
//        let item2 = Item(context: self.context)
//        item2.title = "2. Leet code everyday."
//        item2.done = false
//        itemArray.append(item2)
//
//        let item3 = Item(context: self.context)
//        item3.title = "3. Visit App Store and study one app daily."
//        item3.done = false
//        itemArray.append(item3)
//
//        let item4 = Item(context: self.context)
//        item4.title = "4. Study about Computer Engineering everyday one hour in the evening."
//        item4.done = false
//        itemArray.append(item4)
//
//        let item5 = Item(context: self.context)
//        item5.title = "5. Study iOS Interview tactics."
//        item5.done = false
//        itemArray.append(item5)
//
//        let item6 = Item(context: self.context)
//        item6.title =  "6. Research regarding tech companies daily."
//        item6.done = false
//        itemArray.append(item6)
//
//        let item7 = Item(context: self.context)
//        item7.title = "7. Work on modules of WWDC 2020 daily."
//        item7.done = false
//        itemArray.append(item7)
        
        self.loadItems()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var alertTxtField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item To Do", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            let item = Item(context: self.context)
            item.title = alertTxtField.text!
            item.done = false
            item.parentCategory = self.selectedCategory
            self.itemArray.append(item)
            self.saveItems()
            
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
    
    func saveItems() {
        do {
            try self.context.save()
        } catch {
            print("Problem saving data \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            self.itemArray = try self.context.fetch(request)
        } catch {
            print("Problem fetching data from Core Data Model, \(error)")
        }
        self.tableView.reloadData()
    }

}
//MARK: - Tableview Datasource methods

extension ToDoListViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell") {
            cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
            cell.textLabel?.font = UIFont(name: "Marker Felt", size: 15.0)
            cell.textLabel?.numberOfLines = 0
            
            let item = itemArray[indexPath.row]
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done == true ? .checkmark : .none
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
        print(itemArray[indexPath.row].title!)
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        self.saveItems()
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


// MARK: - UISearchBarDelegate Methods

extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title contains[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        print(searchBar.text!)
        self.loadItems(with: request, predicate: predicate)
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
