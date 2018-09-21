//
//  ViewController.swift
//  StreakIt
//
//  Created by Josh Prochaska on 9/20/18.
//  Copyright © 2018 JoshProchaska. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, AddStreakTypeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, StreakTitleEditButtonDelegate {
    func streakTitleEdited() {
        try? managedObjectContext?.save()
    }

    private var managedObjectContext: NSManagedObjectContext?
    var streakTypes: [StreakType]?
    private var editingTableView: Bool = false
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Streaks"
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
        let delegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = delegate?.persistentContainer.viewContext
        fetchStreaks()
    }

    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        editingTableView = !tableView.isEditing
        for cell in tableView.visibleCells {
            guard let streakCell = cell as? StreakTitleTableViewCell else { continue }
            streakCell.showEditButton(shouldShow: editingTableView)
        }
        tableView.setEditing(!tableView.isEditing, animated: true)
    }

    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? StreakTitleTableViewCell else { return }
        cell.showEditButton(shouldShow: true)
    }

    private func fetchStreaks() {
        let fetchRequest = NSFetchRequest<StreakType>(entityName: String(describing: StreakType.self))
        if let results = try? managedObjectContext?.fetch(fetchRequest) {
            streakTypes = results
        }
    }

    // MARK: - Button Actions
    @objc func addTapped() {
        let addStreakTypeViewController = AddStrekTypeViewController()
        addStreakTypeViewController.delegate = self
        present(addStreakTypeViewController, animated: true, completion: nil)
    }

    @objc func editTapped() {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }

    // MARK: - AddStreakTypeViewController Data Source
    func streakTypeAdded(name: String) {
        guard let context = managedObjectContext else { return }
        let newStreak = StreakType(context: context)
        newStreak.name = name
        guard streakTypes?.contains(newStreak) == false else { return }
        context.insert(newStreak)
        try? context.save()
        streakTypes?.append(newStreak)
        tableView.reloadData()
    }

    // MARK: - Table View Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let streaks = streakTypes else { return 0 }
        return streaks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let streaks = streakTypes, let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? StreakTitleTableViewCell else { return UITableViewCell() }
        cell.setup(streakType: streaks[indexPath.row], isEditing: tableView.isEditing)
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let streaks = streakTypes else { return }
        let streakDetail = StreakDetailViewController()
        streakDetail.prepare(context: managedObjectContext, streakType: streaks[indexPath.row])
        navigationController?.pushViewController(streakDetail, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let context = managedObjectContext, let streak = streakTypes?[indexPath.row] else { return }
        if editingStyle == .delete {
            context.delete(streak)
            streakTypes?.remove(at: indexPath.row)
        }
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}
