//
//  ContentView.swift
//  Phil
//
//  Created by Rene  on 03/10/23.
//

import SwiftUI
import KeychainSwift

struct MainView: View {
    @ObservedObject var loginViewModel = LoginViewModel()
    @ObservedObject var signUpViewModel = SignUpViewModel()
    
    
    
    init() {
        signUpViewModel.loginViewModel = loginViewModel
        
        let keychain = KeychainSwift()
        if let token = keychain.get("userToken"), !TokenHelper.isTokenExpired(token: token) {
            self.loginViewModel.viewState = .ContentsView
        }
        
    }
    
    
    
    
    var body: some View {
            if loginViewModel.isLoggedIn {
                // Si el usuario está loggeado, muestra la TabBarView
                TabBarView(user: 1)
            } else {
                // Si no está loggeado, muestra la vista de login o registro
                switch loginViewModel.viewState {
                case .username:
                    UsernameView(viewModel: loginViewModel)
                case .password:
                    PasswordView(viewModel: loginViewModel)
                case .signUp:
                    SignUpView(viewModel: signUpViewModel)
                default:
                    Text("Bienvenido a la app de Phil")
                }
            }
        }
}
        
    







extension View {
    func flexible() -> some View {
        self.layoutPriority(1)
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}


