//
//  Category.swift
//  Todoey
//
//  Created by Robin Goh on 11/4/18.
//  Copyright © 2018 Robin Goh. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    let items = List<Item>()
}
