//
//  FormFieldValidator.swift

import Foundation
import UIKit

public typealias FormValidationBlock = (String) -> FormFiledValidationResult

public enum FormFiledValidationResult {
    
    case success
    case fail(_validator: FormFieldValidator?)
    
    public var booleanValue: Bool {
        
        switch self {
        case .success:
            return true
        default:
            return false
        }
    }
}

public class FormFieldValidator {
    
    var type : FormFieldValidatorType = .None
    var errorMessage : String
    var mandatory : Bool = true
    var priority: Int = 0
    var validationBlock: FormValidationBlock?
    var validateOnTextChange: Bool = false

    public init(type: FormFieldValidatorType, mandatory : Bool = true, errorMessage : String = "Required", priority: Int = 0, validateOnTextChange: Bool = false) {
        self.type = type
        self.mandatory = mandatory
        self.errorMessage = errorMessage
        self.priority = priority
        self.validateOnTextChange = validateOnTextChange
    }
    
    convenience public init(validationBlock: @escaping FormValidationBlock, mandatory : Bool = true, errorMessage : String = "Required", priority: Int = 0, validateOnTextChange: Bool = false) {
        
        self.init(type: .ValidationBlock, mandatory: mandatory, errorMessage: errorMessage, priority: priority, validateOnTextChange: validateOnTextChange)
        self.validationBlock = validationBlock
    }
    
    public func checkValiditity(forString stringToBeValidated: String) -> Bool {
        
        switch type {
            
        case .MinimumEightCharactesLength:
            return StringValidator.passwordMinimumLength(string: stringToBeValidated)
        case .NonEmpty:
            return StringValidator.nonEmpty(string: stringToBeValidated)
        case .Email:
            return StringValidator.isValidEmail(string: stringToBeValidated)
        case .OneNumber:
            return StringValidator.hasOneNumber(string: stringToBeValidated)
        case .OneCharacter:
            return StringValidator.hasOneSpecialCharacter(string: stringToBeValidated)
        case .OneLowerCasedLetter:
            return StringValidator.hasOneLowercaseCharacter(string: stringToBeValidated)
        case .OneUpperCasedLetter:
            return StringValidator.hasOneUppercaseCharacter(string: stringToBeValidated)
        case .MobileNumber:
            return StringValidator.isValidMobileNumber(string:stringToBeValidated)
        default:
            return (validationBlock?(stringToBeValidated) ?? .success).booleanValue
        }
    }
    
    public static var required: FormFieldValidator {return FormFieldValidator(type: .NonEmpty) }
}
