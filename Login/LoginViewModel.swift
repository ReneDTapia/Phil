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
    @Published var userID : Int = 0
    
    func login() {
        AuthService.shared.login(username: user.username, password: user.password) { result in
            switch result {
            case .success(let data):
                TokenHelper.save(token: data.token, userID: data.userID)
                
                if !TokenHelper.isTokenExpired(token: data.token) {
                    self.viewState = .ContentsView
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
    
    func logout() {
            AuthService.shared.logout()
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


