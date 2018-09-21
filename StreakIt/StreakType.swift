//
//  StreakType.swift
//  StreakIt
//
//  Created by Josh Prochaska on 9/20/18.
//  Copyright © 2018 JoshProchaska. All rights reserved.
//

import UIKit
import CoreData

class StreakType: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var bestStreak: Int16
    @NSManaged var currentStreak: Int16
    @NSManaged var days: Set<StreakDay>

    static func ==(lhs: StreakType, rhs: StreakType) -> Bool {
        return lhs.name == rhs.name
    }
}
