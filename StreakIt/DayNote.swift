//
//  DayNote.swift
//  StreakIt
//
//  Created by Josh Prochaska on 12/16/18.
//  Copyright © 2018 JoshProchaska. All rights reserved.
//

import UIKit
import CoreData

class DayNote: NSManagedObject {
    @NSManaged var note: String
    @NSManaged var day: StreakDay
}
