//
//  DynamicTextField.swift
//  DynamiFormSample
//
//  Created by kartheek.manthoju on 06/12/21.
//

import UIKit
import IQDropDownTextField

class DynamicTextField: IQDropDownTextField {
    var formField: Field? {
        didSet {
            autocorrectionType = .no
            autocapitalizationType = .sentences
            let isAccessoryField = formField?.isAccessoryField ?? false
            textAlignment = (isAccessoryField ? .right : .left)
            textColor = (isAccessoryField ? UIColor.darkGray : UIColor.black)
            var fieldRightView: UIView?
            var fieldMode: IQDropDownMode = .textField
            var keyboardType: UIKeyboardType = .asciiCapable
            if let type = formField?.type {
                switch type {
                case .number:
                    keyboardType = .decimalPad
                case .email:
                    keyboardType = .emailAddress
                case .phone:
                    keyboardType = .phonePad
                case .regular:
                    keyboardType = .asciiCapable
                case .dropdown:
                    keyboardType = .asciiCapable
                    fieldMode = .textPicker
                    fieldRightView = UIImageView(image: UIImage.init(systemName: "chevron.down"))
                case .popup:
                    keyboardType = .asciiCapable
                    fieldRightView = UIImageView(image: UIImage.init(systemName: "chevron.down"))
                case .edit:
                    keyboardType = .asciiCapable
                    fieldMode = .textPicker
                    let button = UIButton()
                    button.setTitle("Edit", for: UIControl.State())
                    button.setTitleColor(.tintColor, for: UIControl.State())
                    button.sizeToFit()
                    fieldRightView = button
                case .call:
                    keyboardType = .asciiCapable
                    fieldRightView = UIImageView(image: UIImage.init(systemName: "phone.fill"))
                case .map:
                    keyboardType = .asciiCapable
                    fieldRightView = UIImageView(image: UIImage.init(systemName: "chevron.right"))
                case .website:
                    keyboardType = .asciiCapable
                    fieldRightView = UIImageView(image: UIImage.init(systemName: "safari.fill"))
                case .date:
                    keyboardType = .asciiCapable
                    fieldMode = .datePicker
                case .time:
                    keyboardType = .asciiCapable
                    fieldMode = .timePicker
                case .dateTime:
                    keyboardType = .asciiCapable
                    fieldMode = .dateTimePicker
                }
            }
            self.keyboardType = keyboardType
            rightView = isAccessoryField ? nil : fieldRightView // do not add right view if textfield is small
            rightViewMode = isAccessoryField ? .never : .always
            dropDownMode = fieldMode
            delegate = self
            placeholder = formField?.placeholder
            addAction(UIAction.init(handler: { action in
                NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "textFieldEditingChanged"), object: self)
            }), for: .editingChanged)
            isEnabled = formField?.isEditable ?? true
        }
    }
}

extension DynamicTextField: IQDropDownTextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "textFieldShouldBeginEditing"), object: self)
        let editable = formField?.isEditable ?? true
        var canEdit = false
        let type = formField?.type ?? .regular
        switch type {
        case .number, .email, .phone, .regular, .dropdown, .edit, .date, .time, .dateTime:
            canEdit = true
        case .popup, .call, .map, .website:
            canEdit = false
        }
        return editable && canEdit
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "textFieldDidEndEditing"), object: self)
    }
    func textField(_ textField: IQDropDownTextField, didSelectItem item: String?, row: Int) {
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "textFieldDidEndEditing"), object: self)
    }
    func textField(_ textField: IQDropDownTextField, didSelect date: Date?) {
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "textFieldDidEndEditing"), object: self)
    }
}
