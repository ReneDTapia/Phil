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
    @Published var userID: Int = 0
    
    func login() {
        AuthService.shared.login(username: user.username, password: user.password) { result in
            switch result {
            case .success(let data):
                TokenHelper.save(token: data.token, userID: data.userID)
                
                // Save username to UserDefaults
                UserDefaults.standard.set(self.user.username, forKey: "username")
                
                if !TokenHelper.isTokenExpired(token: data.token) {
                    self.viewState = .ContentsView
                } else {
                    self.alertMessage = "La sesión ha expirado. Por favor, vuelve a ingresar"
                    self.showAlert = true
                }
            case .failure(let error):
                print("Error logging in: \(error)")
                if let customError = error as? CustomError {
                    switch customError {
                    case .unauthorized:
                        self.alertMessage = "Usuario o contraseña incorrectos. Por favor, intenta de nuevo."
                    case .forbidden:
                        self.alertMessage = "No tienes permiso de realizar esta acción"
                    }
                } else {
                    self.alertMessage = "No se pudo iniciar sesión. Por favor, intenta de nuevo."
                }
                self.showAlert = true
            }
        }
    }
    
    func logout() {
        AuthService.shared.logout()
        // Clear username from UserDefaults
        UserDefaults.standard.removeObject(forKey: "username")
        self.viewState = .username 
    }
    
    var isLoggedIn: Bool {
        let keychain = KeychainSwift()
        if let token = keychain.get("userToken"), !TokenHelper.isTokenExpired(token: token) {
            return true
        }
        return false
    }
    
}


