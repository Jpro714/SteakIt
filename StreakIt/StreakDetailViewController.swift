//
//  StreakDetailViewController.swift
//  StreakIt
//
//  Created by Josh Prochaska on 9/20/18.
//  Copyright © 2018 JoshProchaska. All rights reserved.
//

import UIKit
import CoreData
extension Date {
    func dateString() -> String {
        var calendarComponents = Set<Calendar.Component>()
        calendarComponents.insert(.day)
        calendarComponents.insert(.month)
        calendarComponents.insert(.year)
        let components = Calendar.current.dateComponents(calendarComponents, from: self)
        guard let month = components.month, let day = components.day, let year = components.year else { return "" }
        return "\(month)-\(day)-\(year - 2000)"
    }
}

class StreakDetailViewController: UIViewController, StreakDateCellDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    var streakDays: [StreakDay]?
    var context: NSManagedObjectContext?
    private var type: StreakType?
    private var currentDay: StreakDay?
    private var earliestDayResponseGiven: Date?
    @IBOutlet weak var bestStreakDaysLabel: UILabel!
    @IBOutlet weak var currentStreakDaysLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let streak = type,
            let days = streakDays,
            let managedContext = context
            else { return }
        let currentStreakDay = days.isEmpty ? createStreakDay(context: managedContext, date: Date(), type: streak) : days[0]
        let nib = UINib(nibName: String(describing: StreakDateTableViewCell.self), bundle: nil)
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped(_:))), editButtonItem]
        tableView.register(nib, forCellReuseIdentifier: String(describing: StreakDateTableViewCell.self))
        currentDay = currentStreakDay
        updateViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViews()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(!tableView.isEditing, animated: animated)
    }

    @objc private func addTapped(_ sender: Any) {
        guard let earliestDate = streakDays?.last?.date,
            let streakType = type,
            let context = context,
            let newDate = Calendar.current.date(byAdding: incrementDateComponents(amount: -1), to: earliestDate),
            var days = streakDays
            else { return }
        days.append(createStreakDay(context: context, date: newDate, type:streakType))
        streakDays = days
        try? context.save()
        tableView.reloadData()
    }

    private func updateViews() {
        guard let streak = type else { return }
        let streakData = calcBestStreak()
        bestStreakDaysLabel.text = "\(streakData.best)"
        currentStreakDaysLabel.text = "\(streakData.current)"
        streak.bestStreak = Int16(streakData.best)
        streak.currentStreak = Int16(streakData.current)
        try? context?.save()
        calcEarliestDayResponseGiven()
        tableView.reloadData()
    }

    func prepare(context managedObjectContext: NSManagedObjectContext?, streakType: StreakType) {
        context = managedObjectContext
        type = streakType
        fetchDayData()
        title = streakType.name
        guard let ctx = context else { return }
        if streakDays?.isEmpty == true {
            _ = createStreakDay(context: ctx, date: Date(), type: streakType)
            fetchDayData()
        }
        guard var today = streakDays?[0].date else { return }
        var needsRefresh = false
        while startOfDay(today) != startOfDay(Date()) {
            needsRefresh = true
            guard let tomorrow = Calendar.current.date(byAdding: incrementDateComponents(), to: today) else { continue }
            _ = createStreakDay(context: ctx, date: tomorrow, type: streakType)
            today = tomorrow
        }
        if needsRefresh {
            fetchDayData()
        }
        earliestDayResponseGiven = today
        calcEarliestDayResponseGiven()
    }

    private func calcEarliestDayResponseGiven() {
        guard let days = streakDays else { return }
        
        for day in days {
            if day.responseGiven {
                earliestDayResponseGiven = day.date
            }
        }
    }

    private func createStreakDay(context: NSManagedObjectContext, date: Date, type: StreakType) -> StreakDay {
        let day = StreakDay(context: context)
        day.date = startOfDay(date)
        day.type = type
        try? context.save()
        return day
    }

    private func startOfDay(_ date: Date) -> Date {
        return Calendar.current.startOfDay(for: date)
    }

    private func calcBestStreak() -> (best: Int, current: Int) {
        guard let days = streakDays else { return (best: 0, current: 0) }
        var bestStreak: Int = 0
        var currentStreak: Int = 0
        for day in days.reversed() {
            guard day.success else {
                if day.responseGiven {
                    currentStreak = 0;
                }
                continue
            }
            currentStreak += 1
            bestStreak = currentStreak > bestStreak ? currentStreak : bestStreak
        }

        return (best: bestStreak, current: currentStreak)
    }

    private func incrementDateComponents(amount: Int = 1) -> DateComponents {
        var components = DateComponents()
        components.day = amount
        return components
    }

    func yesButtonTapped(cell: StreakDateTableViewCell, day: StreakDay) {
        day.responseGiven = !day.success
        day.success = !day.success
        try? context?.save()
        updateViews()
    }

    func noButtonTapped(cell: StreakDateTableViewCell, day: StreakDay) {
        day.responseGiven = !day.responseGiven || day.success
        day.success = false
        try? context?.save()
        updateViews()
    }

    private func fetchDayData() {
        guard let context = context, let type = type else { return }
        
        let fetchRequest = NSFetchRequest<StreakDay>(entityName: String(describing: StreakDay.self))
        fetchRequest.predicate = NSPredicate(format: "type == %@", type)

        streakDays = try? context.fetch(fetchRequest).sorted(by: { (day1, day2) -> Bool in
            day1.date > day2.date
        })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let days = streakDays else { return 0 }
        return days.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let days = streakDays, let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: StreakDateTableViewCell.self)) as? StreakDateTableViewCell else { return UITableViewCell() }
        let day = days[indexPath.row]
        cell.setup(day: day)
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let context = context, let day = streakDays?[indexPath.row] else { return }
        if editingStyle == .delete {
            context.delete(day)
            streakDays?.remove(at: indexPath.row)
        }

        tableView.deleteRows(at: [indexPath], with: .automatic)
        try? context.save()
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let days = streakDays, let earliestDay = earliestDayResponseGiven else { return true }
        return days[indexPath.row].date < earliestDay
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let context = context, let dayType = streakDays?[indexPath.row] else { return }
        let addNoteViewController = AddDayNoteViewController()
        addNoteViewController.prepare(context: context, day: dayType)
        navigationController?.pushViewController(addNoteViewController, animated: true)
    }
}
