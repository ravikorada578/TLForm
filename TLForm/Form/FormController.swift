    //
//  FormController.swift

import Foundation
import UIKit

public protocol FormControllerDelegate: class {
    
    //Calls when the validation of a type is changed
    func onFormValidationDidChange(valid: Bool, type: FormFieldType, inSection section: Int, showError: Bool)
    
    //Calls when the total validation of the form is changed
    func onFormValidationDidChange(valid: Bool)
    
    //Calls to customize the cell before it gets loaded
    func designCell(cell: FormTableViewCell, ofType type: FormFieldType, inSection section: Int )
    
    func viewAt(section: Int) -> UIView?
    
    func sectionHeightAt(section: Int) -> CGFloat
    
    //Calls when the field gets selected
    func onFormFieldDidSelect(type: FormFieldType, inSection section: Int)
    
    //Calls when the field gets focused
    func formFieldFocused(type: FormFieldType, inSection section: Int)
    
    //Calls when the field gets focused
    func formFieldUnFocused(type: FormFieldType, inSection section: Int)
}

extension FormControllerDelegate {
    
    func onFormValidationDidChange(valid: Bool, type: FormFieldType, inSection section: Int, showError: Bool) {}
    func onFormValidationDidChange(valid: Bool) {}
    func designCell(cell: FormTableViewCell, ofType type: FormFieldType, inSection section: Int ) {}
    func onFormFieldDidSelect(type: FormFieldType, inSection section: Int) {}
    func formFieldFocused(type: FormFieldType, inSection section: Int) {}
    func viewAt(section: Int) -> UIView? {return nil}
    func sectionHeightAt(section: Int) -> CGFloat {return 0.1}
    func formFieldUnFocused(type: FormFieldType, inSection section: Int) {}
}

public class FormCellStorage: FormCellStorageContainer {
    public var cellStorage: [FormFieldType: FormTableViewCell] = [:]
}

public protocol FormCellStorageContainer: class {
    
    var cellStorage: [FormFieldType: FormTableViewCell] {get set}
    
    func cellForFormType(type: FormFieldType) -> FormTableViewCell
    func setErrorOnCellType(_ type: FormFieldType, errorMessage: String)
    func removeErrorOnCellType(_ type: FormFieldType)
    func getNewFormTableViewCell(type: FormFieldType) -> FormTableViewCell
}

extension FormCellStorageContainer {
    
    public func cellForFormType(type: FormFieldType) -> FormTableViewCell {
        
        if cellStorage[type] == nil {
            cellStorage[type] = getNewFormTableViewCell(type: type)
        }
        return cellStorage[type]!
    }
    
    public func setErrorOnCellType(_ type: FormFieldType, errorMessage: String) {
        cellStorage[type]?.setError(errorMessage: errorMessage)
    }
    
    public func removeErrorOnCellType(_ type: FormFieldType) {
        cellStorage[type]?.setError(errorMessage: nil)
    }
    
    public func getNewFormTableViewCell(type: FormFieldType) -> FormTableViewCell {
        return UINib(nibName: "FormTableViewCell", bundle: Bundle(for: FormTableViewCell.self)).instantiate(withOwner: nil, options: nil).first as! FormTableViewCell
    }
}

public class FormController: NSObject {
    
    public var formFields: [FormFieldData] {
        
        return tableData.reduce(into: []) { (prev, next) in
            return prev.append(contentsOf: next)
        }
    }
    
    public var tableData: [[FormFieldData]] = []
    
    public weak var delegate: FormControllerDelegate?
    
    public var cellSource: FormCellStorageContainer! = FormCellStorage()
    
    func formFieldData(forType type: FormFieldType) -> FormFieldData {
        return formFields.filter({$0.type == type}).first!
    }
    
    func formFieldCell(forType type: FormFieldType) -> FormTableViewCell {
        return cellSource.cellForFormType(type:type)
    }
    
    func valuesOfAllField() -> [FormValue?] {
        return cellSource.cellStorage.values.map{$0.formValue}
    }
    
    func indexPathFor(type: FormFieldType) -> IndexPath? {
        
        for (section,items) in tableData.enumerated() {
            for (row, item) in items.enumerated() {
                if item.type == type {
                   
                    return IndexPath(row:row, section: section)
                }
            }
        }
        return nil
    }
    
    func valueOfType(type : FormFieldType) -> FormValue? {
        
        return formFieldData(forType: type).formValue
    }
    
    func setValueForType(type : FormFieldType, value: FormValue?) {
        
        self.formFieldData(forType: type).formValue = value
    }
    
    func enable(ofType type: FormFieldType) {
        self.formFieldCell(forType: type).formTextField?.isEnabled = true
    }
    
    func disable(ofType type: FormFieldType) {
        self.formFieldCell(forType: type).formTextField?.isEnabled = false
    }
    
    func focusField(ofType type: FormFieldType) {
        
//        let formFieldData = self.formFieldData(forType: type)
//        let cell = formFieldCell(forType: type)
//        if formFieldData.showSelectionList && formFieldData.isEditable &&  formFieldData.scopeValues.count > 0 {
//
//            var rect: CGRect = .zero
//            if let txtField = cell.formTextField {
//
//                var v: UIView = cell.superview!
//                while (v.superview != nil) {
//                    v = v.superview!
//                }
//                rect = cell.convert(txtField.frame, to: v)
//            }
//            cell.didShowSelectionList()
//            SelectionListPresenter.shared.presentSelectionList(withData: formFieldData.scopeValues, selectedEntity: formFieldData.formValue, onVC: (delegate as! UIViewController).navigationController!, delegate: cell ,selectionRect: rect)
//        } else {
            self.formFieldCell(forType: type).formTextField?.becomeFirstResponder()
//        }
    }
}

extension FormController: FormTableViewCellDelegate {
    
    public func fieldFocused(type: FormFieldType, inSection section: Int) {
        
        cellSource.removeErrorOnCellType(type)
        delegate?.formFieldFocused(type: type, inSection: section)
    }
    
    public func fieldUnFocused(type: FormFieldType, inSection section: Int) {
        
        let validationResult = self.validateFormFieldOfType(type: type, showError: true).booleanValue
        delegate?.onFormValidationDidChange(valid: validationResult, type: type, inSection: section, showError: true)
        let _ = validateForm()
        delegate?.formFieldUnFocused(type: type, inSection: section)
    }
    
    public func fieldValueChanged(type: FormFieldType, inSection section: Int) {
        
        let _ = self.validateFormFieldOfType(type: type, onTextChange: true, showError: true).booleanValue
        let _ = validateForm()
    }
}

extension FormController {
    
    func validateForm(showError: Bool = false) -> Bool {
        
        var isFormValid: Bool = true
        for fieldData in formFields {
            isFormValid = isFormValid && self.validateFormFieldOfType(type: fieldData.type, showError: showError).booleanValue
        }
        delegate?.onFormValidationDidChange(valid: isFormValid)
        return isFormValid
    }
    
    func validateFormFieldOfType( type: FormFieldType, onTextChange: Bool = false,showError: Bool =  false, stringToBeValidated: String? = nil) -> FormFiledValidationResult {
        
        let formFieldData = self.formFieldData(forType: type)
        
        let stringToBeValidatedOfInterest = stringToBeValidated ?? formFieldData.formValue ?? ""
        
        let validatorsOfInterest = formFieldData.validators.sorted(by: {$0.priority < $1.priority}).filter({ !onTextChange || $0.validateOnTextChange  })
        
        for validator in  validatorsOfInterest {
            
            var isValid = validator.checkValiditity(forString: stringToBeValidatedOfInterest)
            isValid = isValid || !validator.mandatory
            
            if !isValid {
                if showError {
                    cellSource.setErrorOnCellType(type, errorMessage: validator.errorMessage)
                }
                if let indexPath = indexPathFor(type: type) {
                    delegate?.onFormValidationDidChange(valid: false, type: type, inSection: indexPath.section, showError: showError)
                }
                print("*********Form Invalid on type \(type.type): \(stringToBeValidated ?? "")***********")
                return .fail(_validator: validator)
            }
        }
        
        if showError {
            cellSource.removeErrorOnCellType(type)
        }
        return .success
    }
}

extension FormController: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let formFieldData = tableData[indexPath.section][indexPath.row]
        let cell = formFieldCell(forType: formFieldData.type)
        cell.delegate = self
        cell.section = indexPath.section
        cell.formFieldData = formFieldData
        cell.populateFields()
        delegate?.designCell(cell: cell, ofType: formFieldData.type, inSection: indexPath.section)
        //cell.layoutIfNeeded()
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//        let formFieldData = tableData[indexPath.section][indexPath.row]
//        let cell = tableView.cellForRow(at: indexPath) as? FormTableViewCell
        
//        if formFieldData.showSelectionList && formFieldData.isEditable &&  formFieldData.scopeValues.count > 0 {
//            
//            tableView.endEditing(true)
//            
//            var rect: CGRect = .zero
//            if let txtField = (tableView.cellForRow(at: indexPath) as? FormTableViewCell)?.formTextField {
//                
//                var v: UIView = tableView
//                while (v.superview != nil) {
//                    v = v.superview!
//                }
//                rect = cell!.convert(txtField.frame, to: v)
//            }
//            cell?.didShowSelectionList()
//            SelectionListPresenter.shared.presentSelectionList(withData: formFieldData.scopeValues, selectedEntity: formFieldData.formValue, onVC: (delegate as! UIViewController).navigationController!, delegate: cell ,selectionRect: rect)
//        }
        
        
        delegate?.onFormFieldDidSelect(type: tableData[indexPath.section][indexPath.row].type, inSection: indexPath.section)
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return delegate?.viewAt(section: section)
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return delegate?.sectionHeightAt(section: section) ?? 0.1
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return tableData[indexPath.section][indexPath.row].heightConstraint
    }
}

