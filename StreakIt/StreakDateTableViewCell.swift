//
//  StreakDateTableViewCell.swift
//  StreakIt
//
//  Created by Josh Prochaska on 9/23/18.
//  Copyright © 2018 JoshProchaska. All rights reserved.
//

import UIKit

protocol StreakDateCellDelegate {
    func yesButtonTapped(cell: StreakDateTableViewCell, day: StreakDay)
    func noButtonTapped(cell: StreakDateTableViewCell, day: StreakDay)
}

class StreakDateTableViewCell: UITableViewCell {
    private let borderWidth: CGFloat = 2.0
    private var streakDay: StreakDay?
    var delegate: StreakDateCellDelegate?
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var notesImage: UIImageView!
    let greenColor = UIColor(red: 0, green: 1.0, blue: 107.0/255.0, alpha: 1.0)
    let redColor = UIColor(red: 1.0, green: 64.0/255.0, blue: 113.0/255.0, alpha: 1.0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupButton(button: noButton, color: redColor)
        setupButton(button: yesButton, color: greenColor)
    }

    private func setupButton(button: UIButton, color: UIColor){
        button.layer.cornerRadius = button.frame.size.width / 2.0
        button.layer.borderWidth = borderWidth
        button.layer.borderColor = color.cgColor
    }

    @IBAction func noButtonTapped(_ sender: Any) {
        guard let day = streakDay else { return }
       delegate?.noButtonTapped(cell: self, day: day)
    }

    @IBAction func yesButtonTapped(_ sender: Any) {
        guard let day = streakDay else { return }
        delegate?.yesButtonTapped(cell: self, day: day)
    }

    func setup(day: StreakDay){
        dayLabel.text = day.date.dateString()
        streakDay = day
        notesImage.isHidden = !day.hasNote
        yesButton.backgroundColor = day.responseGiven && day.success ? greenColor : .clear
        noButton.backgroundColor = day.success || !day.responseGiven ? .clear : redColor
    }
}
