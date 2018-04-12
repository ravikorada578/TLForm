//
//  FormFieldData.swift

import Foundation
import UIKit

public enum FormKeyboardType {
    case normal, email, numberpad, decimalpad, datepicker, picker
}

open class FormFieldData {
    
    //Unique identification of formFieldData
    var type: FormFieldType = .Title

    var placeHolderText: String!
    var formKeyboardType: FormKeyboardType = .normal
    var shouldValidateOnTextChange: Bool
    var imageName: String = ""
    var validators: [FormFieldValidator] = []
    var defaultErrorMessage: String
    var heightConstraint : CGFloat = 70
    var shouldCheckValidationForAll : Bool
    
    var isEditable: Bool = true
    var emptyValue: FormValue?
    
    var dateFormat: String? = "dd/MM/YYYY"
    var datePickerMode: UIDatePickerMode = .date
    
    var scopeValues: [String] = []
    var showSelectionList: Bool = false
    
    var formValue: FormValue? = "" {
        didSet {
            onChangeFormValue?(formValue)
        }
    }
    
    var onChangeFormValue: ((FormValue?) -> Void)?
    
    public init(placeHolderText: String, type : FormFieldType,imageName: String = "",  validators: [FormFieldValidator] = [], formKeyboardType: FormKeyboardType = .normal, heightConstraint:CGFloat = 75, defaultErrorMessage: String = "Required", shouldValidateOnTextChange: Bool = false, shouldCheckValidationForAll: Bool = false, isEditable: Bool = true) {

        
        self.placeHolderText = placeHolderText
        self.type = type
        self.validators = validators
        self.formKeyboardType = formKeyboardType
        self.imageName = imageName
        self.heightConstraint = heightConstraint
        self.defaultErrorMessage = defaultErrorMessage
        self.shouldValidateOnTextChange = shouldValidateOnTextChange
        self.shouldCheckValidationForAll = shouldCheckValidationForAll
        self.isEditable = isEditable
    }
    
    convenience public init(formValue: FormValue? = nil, emptyValue: FormValue? = "", onFormValueChange: ((FormValue?) -> Void)? = nil, placeHolderText: String, type : FormFieldType,imageName: String = "",  validators: [FormFieldValidator] = [],formKeyboardType: FormKeyboardType = .normal, heightConstraint:CGFloat = 75, defaultErrorMessage: String = "Required", shouldValidateOnTextChange: Bool = false, shouldCheckValidationForAll: Bool = false, isEditable: Bool = true, showSelectionList: Bool = false, scopeValues: [String] = []) {
        
        self.init(placeHolderText: placeHolderText, type: type, imageName: imageName, validators: validators,formKeyboardType: formKeyboardType, heightConstraint: heightConstraint, defaultErrorMessage: defaultErrorMessage, shouldValidateOnTextChange: shouldValidateOnTextChange, shouldCheckValidationForAll: shouldCheckValidationForAll,isEditable: isEditable)
        self.formValue = formValue == nil || formValue == "" ? (emptyValue ?? "") : formValue
        self.emptyValue = emptyValue
        self.onChangeFormValue = onFormValueChange
        //self.onChangeFormValue?(self.formValue)
        self.showSelectionList = showSelectionList
        self.scopeValues = scopeValues
    }
}

extension FormFieldData: Equatable {
    
    public static func ==(lhs: FormFieldData, rhs: FormFieldData) -> Bool {
        return lhs.type == rhs.type
    }
}
