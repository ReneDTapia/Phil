//
//  UserInputValidator.swift
//  Phil
//
//  Created by Rene  on 09/10/23.
//

import Foundation

struct UserInputValidator {
    
    static func isValidEmail(_ email: String) -> Bool {
        let pattern = "^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
    }
    
    static func passwordValidationError(_ password: String) -> String? {
        if !hasUppercase(password) {
            return "Password must have at least one uppercase character."
        }
        if !hasLowercase(password) {
            return "Password must have at least one lowercase character."
        }
        if !hasNumber(password) {
            return "Password must have at least one number."
        }
        if !hasSpecialCharacter(password) {
            return "Password must have at least one special character."
        }
        if password.count < 8 {
            return "Password must be at least 8 characters long."
        }
        return nil
    }
    
    static private func hasUppercase(_ password: String) -> Bool {
        let uppercaseRegEx = ".*[A-ZÑ]+.*"
        return NSPredicate(format: "SELF MATCHES %@", uppercaseRegEx).evaluate(with: password)
    }
    
    static private func hasLowercase(_ password: String) -> Bool {
        let lowercaseRegEx = ".*[a-zñ]+.*"
        return NSPredicate(format: "SELF MATCHES %@", lowercaseRegEx).evaluate(with: password)
    }
    
    static private func hasNumber(_ password: String) -> Bool {
        let numberRegEx = ".*[0-9]+.*"
        return NSPredicate(format: "SELF MATCHES %@", numberRegEx).evaluate(with: password)
    }
    
    static private func hasSpecialCharacter(_ password: String) -> Bool {
        let specialCharacterRegEx = ".*[!&^%$#@()/._-]+.*"
        return NSPredicate(format: "SELF MATCHES %@", specialCharacterRegEx).evaluate(with: password)
    }
}

