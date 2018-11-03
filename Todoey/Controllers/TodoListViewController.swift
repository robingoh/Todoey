//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Robin Goh on 11/2/18.
//  Copyright © 2018 Robin Goh. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    //MARK: - Persistence Storage
    let defaults = UserDefaults.standard
    let TODO_ARRAY_KEY = "todoArray"
    
    var todoArray = [TodoItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var item = TodoItem()
        item.name = "dispose food"
        todoArray.append(item)
        
        item = TodoItem()
        item.name = "complete ios course"
        todoArray.append(item)
        
        for _ in 1...30 {
            item = TodoItem()
            item.name = "sleep early"
            todoArray.append(item)
        }
        
        if let array = defaults.array(forKey: TODO_ARRAY_KEY) as? [TodoItem] {
            todoArray = array
        }
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
        print(todoArray[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
        
        todoArray[indexPath.row].isDone = !todoArray[indexPath.row].isDone
        
        tableView.reloadData()
    }
    
    //MARK: - Add new todo
    @IBAction func addNewTodo(_ sender: UIBarButtonItem) {
        var todoTextField = UITextField()
        
        let alert = UIAlertController(title: "Add new todo", message: "", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { (alertAction) in
            if let userText = todoTextField.text {
                let userTodoItem = TodoItem()
                userTodoItem.name = userText
                self.todoArray.append(userTodoItem)
            
                // Save to UserDefaults
//                self.defaults.set(self.todoArray, forKey: self.TODO_ARRAY_KEY)
                // Reload tableview to display newest update
                self.tableView.reloadData()
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
    
    
}

