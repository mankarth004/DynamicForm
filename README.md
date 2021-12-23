# Gigi-iOS Project



## Environment
    1. This app runs on iPhone
    2. Application is developed using Swift(v-5) language using Xcode(v-13.x) IDE
    3. Deployment target is iOS 11.0

## Architecture
    Using MVVM architecture for neat, modular code. Every Module with folders has its own MVVM structure

## Dependencies and sources
	Making the use of following depencies
1.	SideMenuSwift (https://github.com/kukushi/SideMenu) for right side menu
2.	IQKeyboardManager (https://github.com/hackiftekhar/IQKeyboardManager) to handle the keyboard in scrollable content
3.	IQDropDownTextField (https://github.com/hackiftekhar/IQDropDownTextField) to have pickerview and datepicker in textfields
4.	SwipeCellKit (https://github.com/SwipeCellKit/SwipeCellKit) to handle swipe actions for transactions while tagging

## Implementation
### UI Preparation
    Using Storyboards and nibs with Autolayouts to prepare the UI. Took the help of multiple storyboards for collaborative work to minimize the conflicts.

### Dynamic Form
Make use of well defined and implemented dynamic form to create your forms.
Prepare a json according to your requirement in the following format
```
  {
   "formFieldSections":[
      {
          "title": "Amount",
          "displaySequence": 0,
          "fields": [
              {
                  "title": "Amount",
                  "placeholder": "$0.00",
                  "attributeName": "amount",
                  "displaySequence": 0,
                  "regex": "^(?:|0|[1-9]\\d*)(?:\\.\\d*)?$",
                  "regexValidationMessage": "Please enter valid input for amount",
                  "type": "number",
                  "isEditable": true,
                  "isMandatory": true,
                  "validationMessage": "Please enter amount",
                  "parentField": "another field's attribute name to have child-parent dependency",
                  "config": {
                    "items": ["a", "b", "c"], // to supply dropdown values
                    "format": "dd/MM/yyy" // to supply date format if type is date
                  }
              }
          ]
      }],
      "fieldValues":{
       "amount": "1234"
      }
   }
```
Use "fieldValues" to supply default values.
1. Drop a container view in the required viewcontroller, take a tableViewController and change class name to "DynamicFormViewController" and embed this in the container view.
2. Declare a variable "dynamicForm" and make use of prepareForSegue function
  ```
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dynamicForm = segue.destination as? DynamicFormViewController {
            self.dynamicForm = dynamicForm
        }
    }
  ```
  In viewDidLoad(),
  ```
  JsonLoader.loadJson(filename: index == .zero ? "TransactionDetailForm" : "TransactionDetailFormPersonal", T: Form.self) { response in
            self.dynamicForm?.formData = response
            self.dynamicForm?.sourceViewController = self
            self.dynamicForm?.updateFormDataWith(itemList: ["Software", "Real Estate", "Communications"], for: "businessCategory")
        }
   ``` 

### Json Loader
Load your local json files and get response accordingly by specifying required type
```
JsonLoader.loadJson(filename: "TransactionDetailForm", T: Form.self) { response in
            // your code
        }
```
### Setting text attributes for UI controls
#### attributes for UILabel
```
titleLabel.setAttributes(type: .headerTitle)
```
#### attributes for UIButton
```
nextButton.setAttributes(type: .primaryButton)
```
Refer ObjectAtttibuteManager.swift file for all types of UI control types

Note: Please set text before applying attributes
### BaseViewController
  Subclass from this class to conform to Routable protocol which is very handy for navigation stack
### Routable Protocol
  A shortcut way to navigate to next screen
  ```
  show(storyboard: .moreAboutYou, identifier: .moreAboutYou, configure:  { (controller: MoreAboutYouViewController) in
            // pass data from her
            })
   ```
### App Constants
  Reduce the pain of hardcoded values by specifying the variables here and use them
  1. Inter constants - ``` let kInt0 = 0 ```
  2. Float constants - ``` let kFloat05 = 0.5 ```
  3. Image constants - ``` let kDownArrowImage = "arrow.up.arrow.down" ```
  4. String constants - ``` let kOk = "OK" ```
  5. ViewController specific constants

### Clear cache
  Call the following function in AppDelegate to clear all cache
  ```
  func clearCache() {
        UserDefaults.didCompleteQuestionair = false
        UserDefaults.shouldHideSummaryPopup = false
        UserDefaults.didShowStartReviewScreen = false
        GigiKeychainWrapper.standard.setUsername(nil)
    }
 ```
### Theme Attributes Json
Refer ``` Gigi.json ``` file for all theme related attributes and add your own as per your requirement and update the ``` ThemeModel.swift ``` file accordingly.

### Application fonts
  Using ``` HelveticaNeueLTStd ``` fonts family. All the fonts are added in "Fonts" folder under "Resources"
  
### UIColor Extension
1. ``` static func hexColor(_ hex: String) -> UIColor ```
2. ``` class func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat=1.0) -> UIColor ```

### String Extension
1. ``` var dollarPattern: String ```
2. ``` func validate(regex: String?) -> Bool ```
3. ``` func convertDate(fromFormat: String) -> Date ```
4. ``` var urlEncoded: String ```

### UIViewController Extension
1. ``` func showAlert(_ message: String?, completion: (() -> ())? = nil) ```
2. ``` func setTitle(_ title: String, andImage image: UIImage?) ``` to set the image and title on the UINavigationBar
3. ``` var enableLargeTitles: Bool ``` to enable/disable large titles
4. ``` func showActivityIndicator() ```

### UIView Entension
1. ``` func applyLeadingConstraint(equalTo: NSLayoutXAxisAnchor, constant: CGFloat)
    func applyTrailingConstant(equalTo: NSLayoutXAxisAnchor, constant: CGFloat)
    func applyLeftConstraint(equalTo: NSLayoutXAxisAnchor, constant: CGFloat)
    func applyRightConstraint(equalTo: NSLayoutXAxisAnchor, constant: CGFloat)
    func applyTopConstraint(equalTo: NSLayoutYAxisAnchor, constant: CGFloat)
    func applyBottomConstraint(equalTo: NSLayoutYAxisAnchor, constant: CGFloat)
    func applyHorizontalCenterConstraint(equalTo: NSLayoutXAxisAnchor)
    func applyVerticalCenterConstraint(equalTo: NSLayoutYAxisAnchor) ```

### UIImage Extension
1. ``` func resizeTo( size newSize:CGSize) -> UIImage ```
2. ``` public func mask(with color: UIColor) -> UIImage ```
3. ``` static func image(with name: String) -> UIImage ``` Use this function to maintain backward compatibility. If system image is not present it will pick the asset image ```
4. ``` func textEmbeded(string: String, isImageBeforeText: Bool = true, segFont: UIFont? = nil) -> UIImage ``` use this function to embed image and text anywhere ex: UISegmentedControl

### GigiLogger 
- Use this logger to print anything which will only work in development not in live
-   ```` GigiLogger.dPrint("Error!! Unable to parse  \(filename).json") ````

### UITableView Extension
- ``` func fillSeparator(_ left: CGFloat = .zero, right: CGFloat = .zero) ```
- ``` func registerCell(with identifiers: [String]) ```
- ``` func registerHeaderFooterCell(with identifiers: [String]) ```

### Bundle Extension
- ``` var releaseVersionNumber: String? ```
- ``` var buildVersionNumber: String? ```

### Notification.Name Extension
  Mention all your notification name strings in this extension ex: ``` static var textFieldShouldBeginEditing: Self {
        return .init(rawValue: "textFieldShouldBeginEditing")
    } ```
    
### Date Extension
  ``` func toString(format: String?) -> String? ```
  
## Application Modules 
- Onboarding 
- GetStarted
  - Login
  - MoreAboutYou
  - Select Your Work
  - Connect Financial Accounts
- Dashboard
  - Home
    - Accounts
      - Transactions  
  - Activity
    - Income
      - Add Income
      - Review Income
    - Expense
      - Add Expense
      - Review Expenses 
    - Taxes
      - Setup Tax
      - Add Tax
      - Tax Profile 
  - Gigs(Dummy screens) 
- Utility Classes
  - Common Search
  - Reusable Slider

### Mock all scenarios in Summary screen
 1. Added a dummy barbutton item beside menu button on summary screen.
 2. An action sheet will be opened with all scenarios on clicking of the button.
 3. Select any option and the screen will be rendered accordingly.
    Note: This button should be removed once the APIs are integrated.
