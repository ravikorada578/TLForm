//
//  FormFieldValidatorType.swift

import Foundation

public enum FormFieldValidatorType: String {
    
    case Email
    case MinimumEightCharactesLength
    case MinimumSevenCharacetersAndOneLetterOneCharacter
    case NoSequence
    case NoRepetition
    case MobileNumber
    case SpecialCharacters
    case NonEmpty
    case OneCharacter
    case MinimumTwoEnglishLetters
    case None
    case ValidationBlock
    case MinimumTwoCharacters
    case MaximumHundredCharacters
    case AllowedCharacters
    case OneNumber
    case OneLowerCasedLetter
    case OneUpperCasedLetter
    case Date
}
