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
    
    var todoArray = ["dispose food", "complete ios course", "sleep early"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let array = defaults.array(forKey: TODO_ARRAY_KEY) as? [String] {
            todoArray = array
        }
    }

    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        cell.textLabel?.text = todoArray[indexPath.row]
        return cell
    }
    
    //MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(todoArray[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
    }
    
    //MARK: - Add new todo
    @IBAction func addNewTodo(_ sender: UIBarButtonItem) {
        var todoTextField = UITextField()
        
        let alert = UIAlertController(title: "Add new todo", message: "", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { (alertAction) in
            if let userText = todoTextField.text {
                self.todoArray.append(userText)
                
                self.defaults.setValue(self.todoArray, forKey: self.TODO_ARRAY_KEY)
                
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

