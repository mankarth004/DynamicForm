//
//  ViewController.swift
//  DynamiFormSample
//
//  Created by kartheek.manthoju on 06/12/21.
//

import UIKit

class ViewController: UIViewController {

    private var dynamicForm: DynamicFormViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dynamic Form Sample"
        dynamicForm?.formData = loadJSON(filename: "AddIncomeForm")
        dynamicForm?.updateFormDataWith(itemList: ["Mobile deposit", "Direct deposit"], for: "transactionType")
        dynamicForm?.updateFormDataWith(itemList: ["Software", "Creative"], for: "businessCategory")
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dynamicForm = segue.destination as? DynamicFormViewController {
            self.dynamicForm = dynamicForm
        }
    }
    private func loadJSON(filename: String) -> Form? {
        if let url = Bundle.main.url(forResource: filename, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let response = try decoder.decode(Form.self, from: data)
                return response
            } catch {
                print("Error!! Unable to parse  \(filename).json")
            }
        }
        return nil
    }
    
    @IBAction func gotoSecondVC(_ sender: Any) {
        performSegue(withIdentifier: "secondVC", sender: nil)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        if dynamicForm?.isValid == true {
            print(dynamicForm?.formData?.fieldValues!)
        }
    }
}

