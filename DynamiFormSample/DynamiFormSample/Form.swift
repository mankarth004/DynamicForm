//
//  Form.swift
//  DynamiFormSample
//
//  Created by kartheek.manthoju on 06/12/21.
//

import Foundation
import SwiftyJSON

// MARK: - Form
class Form: Codable {
    internal init(formFieldSections: [FormFieldSection]?, fieldValues: JSON?) {
        self.formFieldSections = formFieldSections
        self.fieldValues = fieldValues
    }
    let formFieldSections: [FormFieldSection]?
    var fieldValues: JSON?
}

// MARK: - FormFieldSection
struct FormFieldSection: Codable {
    let title: String?
    let displaySequence: Int?
    let fields: [Field]?
}

// MARK: - Field
struct Field: Codable {
    let title, placeholder, attributeName: String?
    let displaySequence: Int?
    let regex: String?
    let type: FieldType?
    let isEditable, isMandatory: Bool?
    let validationMessage, parentField, regexValidationMessage: String?
    let isAccessoryField: Bool?
}

enum FieldType: String, Codable {
    case number, email, phone, regular, dropdown, popup, edit, call, map, website, date, time, dateTime
}

