//
//  Data.swift
//  Todoey
//
//  Created by Sonali Patel on 12/14/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

// Object is a Base class for creating all Realm Model objects

class Data: Object {
    // Dynamic Dispatch of objective-C
    @objc dynamic var name: String = ""
    @objc dynamic var age: Int = 0
}
