//
//  LoginViewModel.swift
//  Phil
//
//  Created by Rene  on 04/10/23.
//

import Foundation
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var user = User(username: "", password: "")
    @Published var viewState: ViewState = .username
    
    func login() {
        AuthService.shared.login(username: self.user.username, password: self.user.password) { result in
            switch result {
            case .success(let token):
                print("Token received: \(token)")
                // Aquí puedes manejar el inicio de sesión exitoso, guardar el token, cambiar la vista, etc.
            case .failure(let error):
                print("Error logging in: \(error)")
                // Maneja el error, muestra una alerta al usuario, etc.
            }
        }
    }
}



