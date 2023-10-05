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
    var loginViewModel: LoginViewModel?
    @Published var viewState: ViewState = .username
    
    func register() {
        AuthService.shared.register(email: self.user.email, username: self.user.username, password: self.user.password) { result in
            switch result {
            case .success:
                print("Successfully registered!")
                // Aquí puedes manejar el registro exitoso, por ejemplo, llevando al usuario a la pantalla de inicio de sesión o directamente al contenido principal.
            case .failure(let error):
                print("Error registering: \(error)")
                // Maneja el error, muestra una alerta al usuario, etc.
            }
        }
    }



    }


