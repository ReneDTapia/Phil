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
        AuthService.shared.login(username: user.username, password: user.password) { result in
            switch result {
            case .success(let token):
                TokenHelper.save(token: token)
                if !TokenHelper.isTokenExpired(token: token) {
 
                    self.viewState = .home
                } else {
                    self.alertMessage = "Login session has expired. Please log in again."
                    self.showAlert = true
                }
            case .failure(let error):
                print("Error logging in: \(error)")
                if let customError = error as? CustomError {
                    switch customError {
                    case .unauthorized:
                        self.alertMessage = "Incorrect username or password. Please try again."
                    case .forbidden:
                        self.alertMessage = "You do not have permission to perform this action."
                    }
                } else {
                    self.alertMessage = "Failed to log in. Please try again."
                }
                self.showAlert = true
            }
        }
    }
}


