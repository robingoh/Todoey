//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Robin Goh on 11/2/18.
//  Copyright © 2018 Robin Goh. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class TodoListViewController: UITableViewController {
    let realm = try! Realm()
    
    var todoItems: Results<Item>?
    
    var selectedCategory: Category? {
        didSet {
            loadTodoItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        print(dataFilePath!)
        
        tableView.rowHeight = 80.00
    }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath) as! SwipeTableViewCell
        
        if let todoItem = todoItems?[indexPath.row] {
            cell.textLabel?.text = todoItem.name
            cell.accessoryType = todoItem.isDone ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No item added yet"
        }
        cell.delegate = self
        return cell
    }
    
    //MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.isDone = !item.isDone
                    tableView.reloadData()
                }
            } catch {
                print("Error writing item.isDone value, \(error)")
            }
            
        }
    }
    
    
    //MARK: - Add new todo
    @IBAction func addNewTodoButtonPressed(_ sender: UIBarButtonItem) {
        var todoTextField = UITextField()
        
        let alert = UIAlertController(title: "Add new todo", message: "", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (alertAction) in
            if let userTypedText = todoTextField.text {
                if let currentCategory = self.selectedCategory {
                    do {
                        try self.realm.write {
                            let item = Item()
                            item.name = userTypedText
                            item.dateCreated = Date()
                            
                            currentCategory.items.append(item)
                            
                            self.tableView.reloadData()
                        }
                    } catch {
                        print("Error saving new todo item, \(error)")
                    }
                }
            }
        }
        
        alert.addAction(addAction)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Enter new todo"
            todoTextField = textField
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model manipulation methods
    func loadTodoItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "name", ascending: true)
        
        tableView.reloadData()
    }
}

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchTerm = searchBar.text {
            if todoItems?.count != 0 {
                todoItems = todoItems?.filter("name CONTAINS[cd] %@", searchTerm).sorted(byKeyPath: "dateCreated", ascending: true)
                
                tableView.reloadData()
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadTodoItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

// MARK: - SwipeTableViewCell Delegate Methods
extension TodoListViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            if let itemToDelete = self.todoItems?[indexPath.row] {
                do {
                    try self.realm.write {
                        self.realm.delete(itemToDelete)
                        self.tableView.reloadData()
                    }
                } catch {
                    print("Error deleting todo item, \(error)")
                }
            }
            
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "Trash Icon")
        
        return [deleteAction]
    }
    
//    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
//        var options = SwipeOptions()
//        options.expansionStyle = .destructive
//        options.transitionStyle = .border
//        return options
//    }
}
