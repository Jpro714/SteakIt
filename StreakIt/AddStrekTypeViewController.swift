//
//  AddStrekTypeViewController.swift
//  StreakIt
//
//  Created by Josh Prochaska on 9/20/18.
//  Copyright © 2018 JoshProchaska. All rights reserved.
//

import UIKit

protocol AddStreakTypeViewControllerDelegate: NSObjectProtocol {
    func streakTypeAdded(name: String)
}

class AddStrekTypeViewController: UIViewController {
    weak var delegate: AddStreakTypeViewControllerDelegate?
    @IBOutlet weak var streakTextField: UITextField!

    @IBAction func createTapped(_ sender: Any) {
        if let streakName = streakTextField.text, streakName != "" {
            delegate?.streakTypeAdded(name: streakName)
            dismiss(animated: true, completion: nil)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        streakTextField.becomeFirstResponder()
    }

    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
