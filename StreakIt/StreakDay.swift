//
//  StreakDay.swift
//  StreakIt
//
//  Created by Josh Prochaska on 9/20/18.
//  Copyright © 2018 JoshProchaska. All rights reserved.
//

import UIKit
import CoreData

class StreakDay: NSManagedObject {
    @NSManaged var date: Date
    @NSManaged var success: Bool
    @NSManaged var responseGiven: Bool
    @NSManaged var hasNote: Bool
    @NSManaged var type: StreakType
}
