//
//  LoginViewModel.swift
//  Phil
//
//  Created by Rene  on 04/10/23.
//

import Foundation
import SwiftUI
import KeychainSwift


class LoginViewModel: ObservableObject {
    @Published var user = User(username: "", password: "")
    @Published var viewState: ViewState = .username
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    
    func login() {
        let keychain = KeychainSwift()
        AuthService.shared.login(username: self.user.username, password: self.user.password) { result in
            switch result {
            case .success(let token):
                keychain.set(token, forKey: "userToken")
                
                if !TokenHelper.isTokenExpired(token: token) {
                    self.viewState = .home  // Cambiar el estado de la vista para mostrar la pantalla principal
                } else {
                    self.alertMessage = "Your session has expired. Please log in again."
                    self.showAlert = true
                }
            
            case .failure(let error):
                print("Error logging in: \(error)")
                // Aquí puedes manejar el error, por ejemplo, mostrando un mensaje de error al usuario.
                self.alertMessage = "Failed to log in. Please try again."
                self.showAlert = true
            }
        }
    }

}


