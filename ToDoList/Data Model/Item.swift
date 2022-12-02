//
//  Item.swift
//  ToDoList
//
//  Created by halil dikişli on 28.11.2022.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    
    //this for relationship
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items") // we said "items", because in Category we have let items
}
