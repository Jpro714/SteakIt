//
//  AddDayNoteViewController.swift
//  StreakIt
//
//  Created by Josh Prochaska on 10/16/18.
//  Copyright © 2018 JoshProchaska. All rights reserved.
//

import UIKit
import CoreData

class AddDayNoteViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var context: NSManagedObjectContext?
    private var noteType: String?
    private var streakDay: StreakDay?
    private var note: DayNote?
    @IBOutlet weak var imageContainer: UIStackView!
    private let placeholderFontColor: UIColor = .lightGray
    @IBOutlet weak var noteTextView: UITextView!
    private var noteIsEmpty = true
    private let placeholder = "Add Note..."
    private var hasNote: Bool {
        return !noteIsEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = streakDay?.date.dateString() ?? ""
        noteTextView.delegate = self
        noteTextView.text = note?.note ?? ""
        noteIsEmpty = textViewIsEmpty()

        if noteIsEmpty {
            giveTextViewPlaceholder()
        }
    }

    private func giveTextViewPlaceholder() {
        noteTextView.text = placeholder
        noteTextView.textColor = placeholderFontColor
    }

    private func saveContext() {
        streakDay?.hasNote = hasNote
        try? context?.save()
    }

    func textViewIsEmpty() -> Bool {
        return noteTextView.text == ""
    }

    func textViewDidChange(_ textView: UITextView) {
        noteIsEmpty = textViewIsEmpty()
        note?.note = textView.text
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if noteIsEmpty {
            giveTextViewPlaceholder()
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if noteIsEmpty {
            textView.textColor = UIColor.black
            textView.text = ""
        }
    }

    func prepare(context managedObjectContext: NSManagedObjectContext?, day: StreakDay) {
        context = managedObjectContext
        streakDay = day
        noteType = day.type.name + "-" + String(describing: day.date)
        fetchNoteData()
        title = noteType
    }

    override func viewWillDisappear(_ animated: Bool) {
        saveContext()
    }

    private func fetchNoteData() {
        guard let context = context, let day = streakDay else { return }
        let fetchRequest = NSFetchRequest<DayNote>(entityName: String(describing: DayNote.self))
        fetchRequest.predicate = NSPredicate(format: "day == %@", day)
        guard let notes = try? context.fetch(fetchRequest) else { return }

        if notes.isEmpty {
            note = DayNote(context: context)
            note?.note = ""
            note?.day = day
        } else {
            note = notes.first
        }
    }
}
