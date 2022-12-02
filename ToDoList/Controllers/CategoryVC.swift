//
//  CategoryVC.swift
//  ToDoList
//
//  Created by halil dikişli on 28.10.2022.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryVC: SwipeTableVC {
    
    let realm = try! Realm()

    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        tableView.rowHeight = 75
        tableView.separatorStyle = .none
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        setSatatusBarColour(.white)
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(hexString: "000000") as Any]
    }

    
    // MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return categories?.count ?? 1
       }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // This cell call the super class which is in SwipeTableVC, and get the cell info from there
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added"
        
        if let cellBGColour =  UIColor(hexString:categories![indexPath.row].colour) {
            cell.textLabel?.textColor = ContrastColorOf(cellBGColour, returnFlat: true)
        }
        cell.textLabel?.font = .boldSystemFont(ofSize: 18)
        
        if let bgColour = categories?[indexPath.row].colour {
            cell.backgroundColor = UIColor(hexString: bgColour)
        }
        
        return cell
    }
    
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListVC
        
        if let indexPath = tableView.indexPathForSelectedRow {
            
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
        
    }

    // MARK: - Data Manipulation Methods
    
    func save(category: Category) {
        do {
            try realm.write{
                realm.add(category)
            }
        } catch {
            print("Error saving categories\(error)")
        }
        
        tableView.reloadData()
        
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    // MARK: - Delete Data by Swiping
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Deleting by swipe delete error \(error)")
            }
        }
    }
    
    // MARK: - Change Randomly Category Cell Background Colour
    
    @IBAction func changeColour(_ sender: UIButton) {
        // TO GET THE INDEXPATH
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        let indxPath = tableView.indexPathForRow(at: buttonPosition)
        
        if let indexPath = indxPath {
            let bgColour: String = UIColor.randomFlat().hexValue()
            try! realm.write {
                categories?[indexPath.row].colour = bgColour
            }
        }
        tableView.reloadData()
    }
    
    // MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let bgColour: String = UIColor.randomFlat().hexValue()
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.colour = bgColour
            
            self.save(category: newCategory)
        }
        
        alert.addAction(action)
        
        alert.addTextField { (field) in
            
            textField = field
            textField.placeholder = "Add a new category"
        }
        
        present(alert, animated: true)
        
    }
}

extension CategoryVC {
    func setSatatusBarColour(_ colour: UIColor) {
        navigationController?.navigationBar.backgroundColor = colour
        //Status Bar Background Colour
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let statusBar = UIView()
        let _: Void? = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first?.addSubview(statusBar)
        
        statusBar.frame = (window?.windowScene?.statusBarManager!.statusBarFrame)!
        statusBar.backgroundColor = colour
    }
}



