//
//  StringValidator.swift

import Foundation

struct StringValidator {
    
    static func isValidMobileNumber(string: String) -> Bool {
    
        let trimmedStr = string.replacingOccurrences(of: " ", with: "")
        return trimmedStr.count >= 6 && trimmedStr.count <= 20
    }
    static func containsOneCharacter(string: String) -> Bool {
        
        return string.rangeOfCharacter(from: CharacterSet.alphanumerics) != nil
    }
    
    static func passwordMinimumLength(string: String) -> Bool {
        
        return string.count >= 8
    }
    
    static func nonEmpty(string: String) -> Bool {
        
        return string.count > 0
    }
    
    static func hasOneNumber(string :String) -> Bool {
        
        return string.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil
    }
    
    static func hasOneSpecialCharacter(string :String) -> Bool {
        return string.rangeOfCharacter(from: CharacterSet(charactersIn: "@#$%")) != nil
    }
    
    static func hasOneLowercaseCharacter(string :String) -> Bool {
        
        return string.rangeOfCharacter(from: CharacterSet.lowercaseLetters) != nil
    }
    
    static func hasOneUppercaseCharacter(string :String) -> Bool {
        
        return string.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil
    }
    
    static func isValidEmail(string :String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: string)
    }
}
