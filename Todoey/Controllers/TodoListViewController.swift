//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Robin Goh on 11/2/18.
//  Copyright © 2018 Robin Goh. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    let realm = try! Realm()
    let originalColor = UIColor.orange
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var todoItems: Results<Item>?
    
    var selectedCategory: Category? {
        didSet {
            loadTodoItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
//        print(dataFilePath!)
        
        tableView.rowHeight = 80.00
        tableView.bounces = true
        tableView.backgroundColor = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: 0.5)
        title = selectedCategory?.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let color = UIColor(hexString: selectedCategory?.color) else { fatalError("color hex string is invalid. \(selectedCategory!)") }
            
            searchBar.barTintColor = color
            searchBar.tintColor = color
        
            setNavBarColor(color: color)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setNavBarColor(color: originalColor)
    }
    
    func setNavBarColor(color: UIColor) {
        guard let navBar = navigationController?.navigationBar else { fatalError("There is no navigation controller.") }
        let contrastColor = UIColor(contrastingBlackOrWhiteColorOn: color, isFlat: true)
        navBar.tintColor = contrastColor
        navBar.barTintColor = color
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: contrastColor!]
    }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let todoItem = todoItems?[indexPath.row] {
            cell.textLabel?.text = todoItem.name
            cell.accessoryType = todoItem.isDone ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No item added yet"
        }
        
        if let selectedCategoryColor = UIColor(hexString: selectedCategory?.color) {
            cell.backgroundColor = selectedCategoryColor.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todoItems!.count))
            let contrastingColor = UIColor(contrastingBlackOrWhiteColorOn: cell.backgroundColor, isFlat: true)
            cell.textLabel?.textColor = contrastingColor
            cell.tintColor = contrastingColor
        }
        
        return cell
    }
    
    //MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
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
            if let userTypedText = todoTextField.text, !userTypedText.isEmpty {
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
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    // MARK: - Delete data from model
    override func deleteCellFromModel(at indexPath: IndexPath) {
        if let itemToDelete = self.selectedCategory?.items[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemToDelete)
                }
            } catch {
                print("Error deleting item from model, \(error)")
            }
        }
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
