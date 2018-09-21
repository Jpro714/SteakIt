//
//  StreakTitleTableViewCell.swift
//  StreakIt
//
//  Created by Josh Prochaska on 12/15/18.
//  Copyright © 2018 JoshProchaska. All rights reserved.
//

import UIKit

protocol StreakTitleEditButtonDelegate {
    func streakTitleEdited()
}

class StreakTitleTableViewCell: UITableViewCell {
    @IBOutlet weak var editingTextField: UITextField!
    @IBOutlet var countLabel: UILabel?
    @IBOutlet var titleLabel: UILabel?
    private var editingTitle: Bool = false
    private var type: StreakType?
    var delegate: StreakTitleEditButtonDelegate?

    @IBAction func editButtonTapped(_ sender: UIButton) {
        if editingTitle {
            finishEditing()
        } else {
            setupEditing()
        }
        editingTitle = !editingTitle
    }

    private func finishEditing() {
        guard let streakType = type, let titleText = editingTextField.text else { return }
        streakType.name = titleText
        titleLabel?.text = titleText
        delegate?.streakTitleEdited()
        editingTextField.isHidden = true
        titleLabel?.isHidden = false
        titleLabel?.setNeedsLayout()
        titleLabel?.layoutIfNeeded()
        editingTextField.resignFirstResponder()
    }

    private func setupEditing() {
        editingTextField.text = titleLabel?.text
        editingTextField.isHidden = false
        titleLabel?.isHidden = true
    }

    func showEditButton(shouldShow: Bool) {
        shouldShow ? setupEditing() : finishEditing()
    }

    func setup(streakType: StreakType, isEditing: Bool) {
        type = streakType
        titleLabel?.isHidden = false
        editingTextField.isHidden = true
        titleLabel?.text = streakType.name
        countLabel?.text = "\(Int(streakType.currentStreak))"
        editingTextField.isHidden = true
        if isEditing {
            showEditButton(shouldShow: true)
        }
    }
}
