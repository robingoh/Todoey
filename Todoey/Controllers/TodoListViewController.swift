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
    let TODO_ARRAY_KEY = "todoArray"
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("todoItem.plist")
    
    var todoArray = [TodoItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTodoArray()
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
                let userTodoItem = TodoItem()
                userTodoItem.name = userText
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
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(self.todoArray)
            try data.write(to: self.dataFilePath!)
        } catch {
            print("Error encoding todoArray, \(error)")
        }
        tableView.reloadData()
    }
    
    func loadTodoArray() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                todoArray = try decoder.decode([TodoItem].self, from: data)
            } catch {
                print("Error loading saved todoArray, \(error)")
            }
        }
    }
    
    
}

