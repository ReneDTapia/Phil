//
//  SignUpViewModel.swift
//  Phil
//
//  Created by Rene  on 04/10/23.
//

import SwiftUI

class SignUpViewModel: ObservableObject {
    @Published var user = RegisteringUser(email: "", username: "", password: "", confirmPassword: "")
    @Published var isDeaf: Bool = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var viewState: ViewState = .signUp
    @Published var isButtonPressed: Bool = false

    
    var loginViewModel: LoginViewModel?
    
    func register() {
            if let validationError = validateUserInputs() {
                alertMessage = validationError
                showAlert = true
                return
            }
            
            AuthService.shared.register(email: user.email, username: user.username, password: user.password, confirmPassword: user.confirmPassword) { result in
                switch result {
                case .success(let data):
                    print("Successfully registered!")
                    
                    // Guardar el token
                    TokenHelper.save(token: data.token, userID: data.userID)
                    
                    self.loginViewModel?.viewState = .ContentsView

                    
                case .failure(let error):
                    print("Error registering: \(error)")
                    self.alertMessage = "Failed to register. Please try again."
                    self.showAlert = true
                }
            }
        }

    private func validateUserInputs() -> String? {
        guard !user.email.isEmpty, !user.username.isEmpty, !user.password.isEmpty, !user.confirmPassword.isEmpty else {
            return "Please fill in all the fields."
        }
        
        guard UserInputValidator.isValidEmail(user.email) else {
            return "Invalid email format."
        }
        
        if let passwordError = UserInputValidator.passwordValidationError(user.password) {
            return passwordError
        }
        
        guard user.password == user.confirmPassword else {
            return "Passwords do not match."
        }
        
        return nil
    }
}


