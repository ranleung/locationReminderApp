//
//  locationReminderApp.swift
//  locationReminderApp
//
//  Created by Randall Leung on 11/4/14.
//  Copyright (c) 2014 Randall. All rights reserved.
//

import Foundation
import CoreData

class Reminder: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var date: NSDate
    @NSManaged var radius: String
    @NSManaged var coordinate: String

}
