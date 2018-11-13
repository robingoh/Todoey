//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Robin Goh on 11/4/18.
//  Copyright © 2018 Robin Goh. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    var categories: Results<Category>?
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }

    // MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No categories added yet"
        cell.backgroundColor = UIColor(hexString: categories?[indexPath.row].color)
        let contrastingColor: UIColor? = UIColor(contrastingBlackOrWhiteColorOn: cell.backgroundColor, isFlat: true)
        cell.textLabel?.textColor = contrastingColor
        cell.tintColor = contrastingColor
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
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = categories?[indexPath.row]
            }
        }
    }
    
    // MARK: - Add new category button
    @IBAction func addNewCategoryButtonPressed(_ sender: UIBarButtonItem) {
        var categoryTextField = UITextField()
        
        let alert = UIAlertController(title: "New category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (alertAction) in
            if let newCategoryName = categoryTextField.text {
                let newCategory = Category()
                newCategory.name = newCategoryName
                newCategory.color = (UIColor.randomFlat()?.hexValue())!
                self.save(category: newCategory)
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
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
                tableView.reloadData()
            }
        } catch {
            print("Error saving categories, \(error)")
        }
    }
    
    func load() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    // MARK: - Delete data after swipe
    override func deleteCellFromModel(at indexPath: IndexPath) {
        if let categoryToDelete = categories?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(categoryToDelete)
                }
            } catch {
                print("Error deleting category from model, \(error)")
            }
        }
    }
}
