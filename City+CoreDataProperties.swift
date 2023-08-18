//
//  City+CoreDataProperties.swift
//  FinalProject
//
//  Created by HuangSai on 2022-08-16.
//  Copyright © 2022 EirianTa. All rights reserved.
//
//

import Foundation
import CoreData


extension City {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<City> {
        return NSFetchRequest<City>(entityName: "City")
    }

    @NSManaged public var name: String?
    @NSManaged public var country: String?

}
