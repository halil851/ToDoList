//
//  Category.swift
//  ToDoList
//
//  Created by halil dikişli on 28.11.2022.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    let items = List<Item>()
    // same thing -- let array: Array<Int> = [1,2,3]
}
