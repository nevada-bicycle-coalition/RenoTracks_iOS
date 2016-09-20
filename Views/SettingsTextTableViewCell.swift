//
//  SettingsTextTableViewCell.swift
//  RenoTracks
//
//  Created by Brian O'Neill on 7/8/16.
//
//

import UIKit

class SettingsTextTableViewCell: UITableViewCell {
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var valueTextField: UITextField!
    
    var pickerInput:UIPickerView? = nil
    
    enum keyboardType {
        case Numeric
        case Email
        case Picker
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    
    func setType(type:keyboardType)  {
        switch type {
        case .Numeric:
            valueTextField.keyboardType = .NumberPad
            valueTextField.placeholder = "12345"
        case .Email:
            valueTextField.keyboardType = .EmailAddress
            valueTextField.placeholder = "name@mail.com"
        case .Picker:
            if let picker = pickerInput {
                valueTextField.inputView = picker
                valueTextField.placeholder = "Choose One"
            }
        }
        
    }
    
    

}
