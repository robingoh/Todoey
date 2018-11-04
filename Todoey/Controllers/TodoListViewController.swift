//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Robin Goh on 11/2/18.
//  Copyright © 2018 Robin Goh. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    //MARK: - Persistence Storage
    let TODO_ARRAY_KEY = "todoArray"
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var todoArray = [TodoItem]()
    var selectedCategory: TodoCategory? {
        didSet {
            loadTodoArray()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        print(dataFilePath!)
    }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let todoItem = todoArray[indexPath.row]
        cell.textLabel?.text = todoItem.name
        cell.accessoryType = todoItem.isDone ? .checkmark : .none
        return cell
    }
    
    //MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        todoArray[indexPath.row].isDone = !todoArray[indexPath.row].isDone
        
        saveTodoArray()
    }
    
    //MARK: - Add new todo
    @IBAction func addNewTodo(_ sender: UIBarButtonItem) {
        var todoTextField = UITextField()
        
        let alert = UIAlertController(title: "Add new todo", message: "", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { (alertAction) in
            if let userText = todoTextField.text {
                let userTodoItem = TodoItem(context: self.context)
                userTodoItem.name = userText
                userTodoItem.isDone = false
                userTodoItem.parentCategory = self.selectedCategory
                
                self.todoArray.append(userTodoItem)
                
                self.saveTodoArray()
            } else {
                print("something off")
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
    func saveTodoArray() {
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
        tableView.reloadData()
    }
    
    func loadTodoArray(with request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest(), with predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)

        if let additionalPredicate = predicate {
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
            request.predicate = compoundPredicate
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            todoArray = try context.fetch(request)
        } catch {
            print("Error reading context, \(error)")
        }
        
        tableView.reloadData()
    }
}

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchTerm = searchBar.text {
            let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
            
            let searchPredicate = NSPredicate(format: "name CONTAINS[cd] %@", searchTerm)
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            
            loadTodoArray(with: request, with: searchPredicate)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            loadTodoArray()
        }
    }
}
