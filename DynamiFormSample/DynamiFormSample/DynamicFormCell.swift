//
//  DynamicFormCell.swift
//  DynamiFormSample
//
//  Created by kartheek.manthoju on 06/12/21.
//

import UIKit
import IQDropDownTextField

class DynamicFormCell: UITableViewCell {
    var formField: Field? {
        didSet {
            let type = formField?.type ?? .regular
            var fieldRightView: UIView?
            var titleString = formField?.title
            switch type {
            case .call:
                fieldRightView = UIImageView(image: UIImage.init(systemName: "phone.fill"))
            case .map:
                fieldRightView = UIImageView(image: UIImage.init(systemName: "chevron.right"))
            case .website:
                fieldRightView = UIImageView(image: UIImage.init(systemName: "safari.fill"))
            default:
                let isAccessoryField = formField?.isAccessoryField ?? false
                let width = (isAccessoryField ? (UIScreen.main.bounds.width * 0.4) : (UIScreen.main.bounds.width-36))
                let textField = DynamicTextField(frame: CGRect(origin: .zero, size: CGSize(width: width, height: 40)))
                textField.formField = formField
                fieldRightView = textField
                titleString = isAccessoryField ? formField?.title : nil
            }
            accessoryView = fieldRightView
            textLabel?.text = titleString
            textLabel?.numberOfLines = 0
            textLabel?.lineBreakMode = .byWordWrapping
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
