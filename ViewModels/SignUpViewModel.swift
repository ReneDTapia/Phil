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
    
    var loginViewModel: LoginViewModel?
    @Published var viewState: ViewState = .username
    
    func register() {
        AuthService.shared.register(email: self.user.email, username: self.user.username, password: self.user.password) { result in
            switch result {
            case .success:
                print("Successfully registered!")
                self.loginViewModel?.viewState = .home
            case .failure(let error):
                print("Error registering: \(error)")
                // Aquí puedes manejar el error, por ejemplo, mostrando un mensaje de error al usuario.
                self.alertMessage = "Failed to register. Please try again."
                self.showAlert = true
            }
        }
    }

}


