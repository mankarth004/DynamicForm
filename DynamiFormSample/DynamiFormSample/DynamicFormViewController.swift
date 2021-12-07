//
//  DynamicFormViewController.swift
//  DynamiFormSample
//
//  Created by kartheek.manthoju on 06/12/21.
//

import UIKit
import SafariServices
import CoreLocation
import MapKit
import Foundation

class DynamicFormViewController: UITableViewController {

    var formData: Form? {
        didSet {
            tableView.reloadData()
        }
    }
    private var itemListDict = [String: [String]]() {
        didSet {
            tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorInset = .zero
        tableView.backgroundColor = UIColor.lightGrey
//        tableView.contentInset = .init(top: 20, left: 0, bottom: 0, right: 0)
        tableView.register(DynamicFormCell.self, forCellReuseIdentifier: "DynamicFormCell")
        NotificationCenter.default.addObserver(forName: Notification.Name.init(rawValue: "textFieldShouldBeginEditing"), object: nil, queue: nil) { notification in
            guard let textField = notification.object as? DynamicTextField, let formField = textField.formField, let sections = self.formData?.formFieldSections else { return }
//            Check for child-parent dependency
            if formField.parentField != nil {
                for section in sections {
                    guard let fields = section.fields else { return }
                    for field in fields {
                        if let fieldId = field.attributeName, fieldId == formField.parentField {
                            let input = self.formData?.fieldValues?.dictionaryObject?[fieldId] as? String
                            if input == nil || input?.isEmpty == true {
                                let alert = UIAlertController.init(title: "Alert", message: field.validationMessage, preferredStyle: .alert)
                                alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                return
                            }
                        }
                    }
                }
            }
            if formField.type == .popup {
                let alert = UIAlertController.init(title: formField.title, message: "", preferredStyle: .actionSheet)
                for i in 1..<5 {
                    let title = "\(formField.title ?? "")\(i)"
                    alert.addAction(UIAlertAction.init(title: title, style: .default, handler: { action in
                        self.updateFormFields(value: title, key: formField.attributeName ?? "")
                        self.tableView.reloadData()
                    }))
                }
                alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            print("Tapped \(formField.title ?? "") and enabled = \(formField.isEditable ?? false)")
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(rawValue: "textFieldEditingChanged"), object: nil, queue: nil) { notification in
            self.updateFormDataFrom(notification: notification)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(rawValue: "textFieldDidEndEditing"), object: nil, queue: nil) { notification in
            self.updateFormDataFrom(notification: notification)
        }
    }
    func coordinates(forAddress address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) {
            (placemarks, error) in
            guard error == nil else {
                print("Geocoding error: \(error!)")
                completion(nil)
                return
            }
            completion(placemarks?.first?.location?.coordinate)
        }
    }
    func updateFormDataWith(itemList: [String], for key: String) {
        itemListDict[key] = itemList
    }
    private func updateFormDataFrom(notification: Notification) {
        guard let textField = notification.object as? DynamicTextField, let formField = textField.formField else { return }
        updateFormFields(value: textField.selectedItem, key: formField.attributeName ?? "")
    }
    private func updateFormFields(value: String?, key: String) {
        if var values = formData?.fieldValues?.dictionaryObject, !key.isEmpty {
            values[key] = value
            formData?.fieldValues?.dictionaryObject = values
            print("Updated values: \(formData?.fieldValues?.dictionaryObject)")
        }
    }
//    MARK: - validate form fields
    var isValid: Bool {
        var isValidField = false
        guard let fieldSections = formData?.formFieldSections?.sorted(by: {$0.displaySequence ?? 0 < $1.displaySequence ?? 0}), let fieldValues = formData?.fieldValues else { return false }
        for section in fieldSections {
            guard let fields = section.fields?.sorted(by: {$0.displaySequence ?? 0 < $1.displaySequence ?? 0}) else { return false }
            for field in fields {
                let input = fieldValues.dictionaryObject?[field.attributeName ?? ""] as? String
                if field.isMandatory == true, input == nil {
                    let alert = UIAlertController.init(title: "Info", message: field.validationMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                    present(alert, animated: true, completion: nil)
                    return false
                }else if let regex = field.regex, input?.validate(regex: regex) == false {
                    let alert = UIAlertController.init(title: "Info", message: field.regexValidationMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                    present(alert, animated: true, completion: nil)
                    return false
                }else {
                    isValidField = true
                }
            }
        }
        return isValidField
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return formData?.formFieldSections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formData?.formFieldSections?.sorted(by: {$0.displaySequence ?? 0 < $1.displaySequence ?? 0})[section].fields?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DynamicFormCell", for: indexPath) as? DynamicFormCell
        cell?.selectionStyle = .none
        let formField = formData?.formFieldSections?.sorted(by: {$0.displaySequence ?? 0 < $1.displaySequence ?? 0})[indexPath.section].fields?.sorted(by: {$0.displaySequence ?? 0 < $1.displaySequence ?? 0})[indexPath.row]
        cell?.formField = formField
        if let textField = cell?.accessoryView as? DynamicTextField, let type = formField?.type {
            if type == .dropdown || type == .edit {
                textField.itemList = itemListDict[formField?.attributeName ?? ""]
            }
            textField.selectedItem = formData?.fieldValues?.dictionaryObject?[formField?.attributeName ?? ""] as? String
        }
        return cell ?? UITableViewCell()
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 48.0)))
        view.backgroundColor = .clear
        let label = UILabel()
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 10).isActive = true
        label.font = UIFont.systemFont(ofSize: 15.0, weight: .light)
        label.textColor = .gray
        label.text = formData?.formFieldSections?.sorted(by: {$0.displaySequence ?? 0 < $1.displaySequence ?? 0})[section].title?.uppercased()
        return view
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let formField = formData?.formFieldSections?.sorted(by: {$0.displaySequence ?? 0 < $1.displaySequence ?? 0})[indexPath.section].fields?.sorted(by: {$0.displaySequence ?? 0 < $1.displaySequence ?? 0})[indexPath.row], let type = formField.type {
            if type == .call {
                if let url = URL(string: (formField.title ?? "")),
                UIApplication.shared.canOpenURL(url) {
                   UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }else if type == .map {
                self.coordinates(forAddress: formField.title ?? "") {
                    (location) in
                    guard let location = location else {
                        return
                    }
                    let placemark = MKPlacemark(coordinate: location)
                    let mapItem = MKMapItem(placemark: placemark)
                    mapItem.name = placemark.name
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: nil)
        //            openMapForPlace(lat: location.latitude, long: location.longitude)
                }
            }else if formField.type == .website {
                let urlString = formField.title ?? ""
                guard let url = URL(string: urlString) else {
                        return
                }
                let safariViewController = SFSafariViewController(url: url)
                self.present(safariViewController, animated: true, completion: nil)
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

public extension UIColor {
    class func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat=1.0) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
    class var lightGrey: UIColor? {
        return UIColor.rgb(red: 242.0, green: 242.0, blue: 246.0)
    }
    class var selectionGrey: UIColor? {
        return UIColor.rgb(red: 209.0, green: 209.0, blue: 214.0)
    }
    
    class var borderGrey: UIColor? {
        return UIColor.rgb(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.16)
    }
    class var logoBlue: UIColor? {
        return UIColor.rgb(red: 28.0, green: 64.0, blue: 190.0)
    }
    class var pageControlBlue: UIColor? {
        return UIColor.rgb(red: 185.0, green: 198.0, blue: 235.0)
    }
    class var subTitleGrey: UIColor? {
        return UIColor.rgb(red: 60.0, green: 60.0, blue: 67.0)
    }
    class var circleGrey: UIColor? {
        return UIColor.rgb(red: 142.0, green: 142.0, blue: 147.0)
    }
    class var circleBlue: UIColor? {
        return UIColor.rgb(red: 10.0, green: 65.0, blue: 197.0)
    }
    class var checkBoxGrey: UIColor? {
        return UIColor.rgb(red: 199.0, green: 199.0, blue: 204.0)
    }
    static var primaryButtonEnabledBackground = UIColor()
    static var primaryButtonDisabledBackground = UIColor()
    static var primaryButtonDisabledTitle = UIColor()
    static var primaryButtonEnabledTitle = UIColor()
    static var communicationLabelDisabled = UIColor()
    static var communicationLabelEnabled = UIColor()
    static var disabledButtonBlueColour = UIColor()
}

extension String {
    func validate(regex: String?) -> Bool {
        guard let regex = regex else { return false }
        let predicate = NSPredicate(format:"SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
}
