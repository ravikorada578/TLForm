
//
//  FormTableViewCell.swift

import Foundation
import UIKit

public struct FormFieldType: Equatable, Hashable {
    
    var type: String
    
    public static let Title: FormFieldType = FormFieldType(type: "Title")
    public static let FirstName: FormFieldType = FormFieldType(type: "FirstName")
    public static let Surname: FormFieldType = FormFieldType(type: "Surname")
    public static let Email: FormFieldType = FormFieldType(type: "Email")
    public static let ConfirmPassword: FormFieldType = FormFieldType(type: "ConfirmPassword")
    public static let Password: FormFieldType = FormFieldType(type: "Password")
    
    public static func ==(lhs: FormFieldType, rhs: FormFieldType) -> Bool {
        return lhs.type == rhs.type
    }
    public var hashValue: Int {
        return type.hashValue
    }
}

public protocol FormTableViewCellDelegate: class {
    
    func fieldFocused(type: FormFieldType,inSection section: Int)
    func fieldUnFocused(type: FormFieldType,inSection section: Int)
    func fieldValueChanged(type: FormFieldType,inSection section: Int)
}

open class FormTableViewCell: UITableViewCell {
    
    @IBOutlet weak var formTextField : UITextField? {
        didSet {
            formTextField?.delegate = self
            formTextField?.addTarget(self, action: #selector(FormTableViewCell.textFieldValueChanged), for: .editingChanged)
        }
    }
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint?
    
    weak var formFieldData: FormFieldData! 
    
    weak var delegate: FormTableViewCellDelegate!
    var section: Int = 0
    
    var datePicker: UIDatePicker? {
        didSet {
            datePicker?.addTarget(self, action: #selector(FormTableViewCell.dateChanged), for: .valueChanged)
        }
    }
    var picker: UIPickerView? {
        didSet {
            picker?.delegate = self
            picker?.dataSource = self
        }
    }
    
    var formValue: FormValue? {
        return formFieldData.formValue
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func setValue(text: String?) {
        self.formTextField?.text = text
    }
    
    func populateFields() {
        
        formTextField?.text = formFieldData.formValue
        formTextField?.placeholder = formFieldData.placeHolderText
        
        switch formFieldData.formKeyboardType {
        case .normal:
            formTextField?.keyboardType = .default
        case .datepicker:
            
            datePicker = UIDatePicker()
            formTextField?.inputView = self.datePicker!
            datePicker!.datePickerMode = formFieldData.datePickerMode
        case .decimalpad:
            formTextField?.keyboardType = .decimalPad
        case .numberpad:
            formTextField?.keyboardType = .numberPad
        case .email:
            formTextField?.keyboardType = .emailAddress
        default:
            break
        }
        
        if formFieldData.type == .Password {
            formTextField?.isSecureTextEntry = true
        } else {
            formTextField?.isSecureTextEntry = false
        }
        
        if formFieldData.showSelectionList {
            self.formTextField?.isEnabled = false
        } else {
            self.formTextField?.isEnabled = formFieldData.isEditable
        }
    }
    
    func setError(errorMessage: String?) {
        
    }
    
    func selectionListDidDismiss() {
        
        delegate.fieldUnFocused(type: formFieldData.type, inSection: section)
    }
    
    func didShowSelectionList() {
        delegate.fieldFocused(type: formFieldData.type, inSection: section)
    }
    
    func didSelectItem(_ item: String) {
        
        formTextField?.text = item
        formFieldData.formValue = item
        delegate.fieldValueChanged(type: formFieldData.type, inSection: section)
    }
    
    @objc open func textFieldValueChanged() {
        
        formFieldData.formValue = formTextField?.text
        delegate.fieldValueChanged(type: formFieldData.type, inSection: section)
    }
    
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate.fieldFocused(type: formFieldData.type, inSection: section)
        
        if formFieldData.formKeyboardType == .datepicker {
            
            if let date = formFieldData.formValue?.dateFromString(withFormat: formFieldData.dateFormat!) {
                datePicker?.date = date
            } else {
                datePicker?.date = datePicker?.minimumDate ?? Date()
                formTextField?.text = datePicker!.date.stringForm(withFormat: formFieldData.dateFormat!)
                formFieldData.formValue = datePicker!.date.stringForm(withFormat: formFieldData.dateFormat!)
            }
        }
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
        
        delegate.fieldUnFocused(type: formFieldData.type, inSection: section)
    }
}

extension String {
    
    func dateFromString(withFormat format: String) -> Date? {
        let df = DateFormatter()
        df.dateFormat = format
        return df.date(from: self)
    }
}

extension Date {
    
    func stringForm(withFormat format: String) -> String {
        
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: self)
    }
}

extension FormTableViewCell: UIPickerViewDataSource, UIPickerViewDelegate {
    
    //TODO : Work in progress
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1
    }
}

extension FormTableViewCell : UITextFieldDelegate, UITextViewDelegate {
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        
        delegate.fieldFocused(type: formFieldData.type, inSection: section)
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        
        delegate.fieldUnFocused(type: formFieldData.type, inSection: section)
        
        if textView.text?.isEmpty ?? false {
            
            textView.text = formFieldData.emptyValue ?? ""
            formFieldData.formValue = formFieldData.emptyValue ?? ""
            delegate.fieldValueChanged(type: formFieldData.type, inSection: section)
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        
        formFieldData.formValue = textView.text
        delegate.fieldValueChanged(type: formFieldData.type, inSection: section)
    }
    
    @objc func dateChanged() {
        
        formTextField?.text = datePicker!.date.stringForm(withFormat: formFieldData.dateFormat!)
        formFieldData.formValue = datePicker!.date.stringForm(withFormat: formFieldData.dateFormat!)
        
        delegate.fieldValueChanged(type: formFieldData.type, inSection: section)
    }
    
    @objc func clearDate() {
        
        formTextField?.text = ""
        
        formFieldData.formValue = formTextField?.text
        delegate.fieldValueChanged(type: formFieldData.type, inSection: section)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if formFieldData.formKeyboardType == .decimalpad {
            
            switch string {
            case "0","1","2","3","4","5","6","7","8","9":
                return true
            case ".":
                let array = Array(textField.text!)
                var decimalCount = 0
                for character in array {
                    if character == "." {
                        decimalCount += 1
                    }
                }
                
                if decimalCount == 1 {
                    return false
                } else {
                    return true
                }
            default:
                let array = Array(string)
                if array.count == 0 {
                    return true
                }
                return false
            }
        }
        return true
    }
}

//extension MFTextField {
//    
//    func setError(errorMessage: String) {
//        var error: NSError? = nil
//        error = self.errorWithLocalizedDescription(localizedDescription: errorMessage)
//        self.setError(error, animated: true)
//    }
//    
//    func errorWithLocalizedDescription(localizedDescription: String) -> NSError? {
//        let userInfo = [NSLocalizedDescriptionKey: localizedDescription]
//        return NSError(domain: "Error", code: 100, userInfo: userInfo)
//    }
//    
//    func applyCustomTheme(placeHolder: String) {
//        
//                self.textColor = UIColor.formFieldValueColor
//                self.tintColor = UIColor.appThemeDarkBlueColor
//        
//                self.defaultPlaceholderColor = .formFieldValuePlaceholderColor
//                self.errorFont = UIFont.muliFont(size: 11)
//                self.placeholderColor = UIColor.formFieldTitleColor
//                self.placeholderAnimatesOnFocus = true
//                self.clearButtonMode = .never
//                self.placeholderFont = UIFont(name: "Muli", size: 15)
//                self.underlineColor = UIColor.formFieldValuePlaceholderColor
//                self.underlineHeight = 1
//                self.underlineEditingHeight = 1
//                self.font = UIFont(name: "Muli", size: 18)
//        
//        let font = UIFont(name: "Muli", size: 18)
//        let attributes = [
//             NSAttributedStringKey.font   : font,
//            ] as [NSAttributedStringKey : AnyObject]
//        
//        let attributedString = NSAttributedString(string:placeHolder, attributes:attributes)
//        self.attributedPlaceholder = attributedString
//    }
//}

