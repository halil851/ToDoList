//
//  ViewController.swift
//  ToDoList
//
//  Created by halil dikişli on 13.10.2022.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListVC: SwipeTableVC {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var todoItems: Results<Item>?
    let realm = try! Realm()
    var sorted = false
    
    let categoryVC = CategoryVC()
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        tableView.rowHeight = 65
        navigationItem.title = selectedCategory?.name
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let colourHex = selectedCategory?.colour {
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller doesn't exist.")}
            navBar.backgroundColor = UIColor(hexString: colourHex)
            
            if let navBarColour = UIColor(hexString: colourHex){
                navBar.barTintColor = navBarColour
                categoryVC.setSatatusBarColour(navBarColour)
                navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
                searchBar.barTintColor = navBarColour
                
                //Navbar title colour
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColour, returnFlat: true)]
            }
        }
    }
    
    
    // MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            
            cell.accessoryType = item.done ? .checkmark : .none
            
            
            // if item's done property true, strike through the items title.
            if item.done {
                cell.textLabel?.attributedText = strikeThrough(item.title)
            } else {
                cell.textLabel?.attributedText = .none
            }
            cell.textLabel?.text = item.title
            
            
            let percentage: CGFloat = CGFloat(indexPath.row) / CGFloat(todoItems!.count) / 3
            let cellBGColour: String = selectedCategory!.colour
            
            
            
            if let colour = UIColor(hexString: cellBGColour)!.darken(byPercentage: percentage) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true) // adjust contrast automaticly
                cell.textLabel?.font = .boldSystemFont(ofSize: 18)
                cell.tintColor = ContrastColorOf(colour, returnFlat: true)
            }
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    // MARK: - Strike Through the item title
    
    func strikeThrough (_ string: String) -> NSMutableAttributedString {
        
        let attributeString =  NSMutableAttributedString(string: string)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                     value: NSUnderlineStyle.single.rawValue,
                                     range: NSMakeRange(0, attributeString.length))

        return attributeString
    }
    
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error updating didSelectRowAt, \(error)")
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - Sort Items by Created Date
    @IBAction func sortByDate(_ sender: UIBarButtonItem) {
        
        sorted = !sorted
        
        todoItems = todoItems?.sorted(byKeyPath: "dateCreated", ascending: !sorted)
        tableView.reloadData()
    }
    
    
    // MARK: - Delete Items bu Swiping
    override func updateModel(at indexPath: IndexPath) {
        var indx = 0
        
        
        if !sorted {    // if sorted method is not active, then you get original indexPath.row
            indx = indexPath.row
        } else {        // if sorted method called, change the indexPath.row, otherwise it deletes the wrong one
            if let count = selectedCategory?.items.count {
                indx = count - 1 - indexPath.row
            }
        }
        
        if let itemForDeletion = selectedCategory?.items[indx] {
            do {
                try realm.write {
                    realm.delete(itemForDeletion)
                }
            } catch {
                print("Deleting by swipe delete error \(error)")
            }
        }
    }
    
    
    // MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            //When the User click the "Add Item"
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                        
                    }
                } catch {
                    print("Error saving newItem \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true)
    }
    
    // MARK: - Model Manupulation Methods
    
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
}

// MARK: - Search Bar Methods

extension ToDoListVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            loadItems()
            
            // When tap the x button to clear all list, it dismiss the keyboard
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

