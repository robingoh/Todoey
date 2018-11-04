//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Robin Goh on 11/4/18.
//  Copyright © 2018 Robin Goh. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    var categoryArray = [TodoCategory]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategoryArray()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryItemCell", for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    // MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToTodoItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTodoItems" {
            let destinationVC = segue.destination as! TodoListViewController
            destinationVC.selectedCategory = categoryArray[tableView.indexPathForSelectedRow!.row]
        }
    }
    
    // MARK: - Add new category button
    @IBAction func addNewCategoryButtonPressed(_ sender: UIBarButtonItem) {
        var categoryTextField = UITextField()
        
        let alert = UIAlertController(title: "New category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (alertAction) in
            if let newCategoryName = categoryTextField.text {
                let newCategory = TodoCategory(context: self.context)
                newCategory.name = newCategoryName
                self.categoryArray.append(newCategory)
                self.saveCategoryArray()
            }
        }
        
        alert.addAction(action)
        alert.addTextField { (textField) in
            categoryTextField = textField
            categoryTextField.placeholder = "Enter new category"
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Data manipulation Methods
    func saveCategoryArray() {
        do {
            try context.save()
        } catch {
            print("Error saving context of categoryArray, \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategoryArray() {
//        let fetchRequest = NSFetchRequest<TodoCategory>(entityName: "TodoCategory")
        let fetchRequest: NSFetchRequest<TodoCategory> = TodoCategory.fetchRequest()
 
        do {
            categoryArray = try context.fetch(fetchRequest)
        } catch {
            print("Error fetching todoCategory, \(error)")
        }
        tableView.reloadData()
    }
}
