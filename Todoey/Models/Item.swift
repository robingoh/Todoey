//
//  Item.swift
//  Todoey
//
//  Created by Robin Goh on 11/4/18.
//  Copyright © 2018 Robin Goh. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var isDone: Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
