//
//  Category.swift
//  Todoey
//
//  Created by Sonali Patel on 12/15/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}
