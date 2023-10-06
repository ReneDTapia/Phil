//
//  ContentView.swift
//  Phil
//
//  Created by Rene  on 03/10/23.
//

import SwiftUI
import KeychainSwift

struct ContentView: View {
    @ObservedObject var loginViewModel = LoginViewModel()
    @ObservedObject var signUpViewModel = SignUpViewModel()

    
    
    init() {
        signUpViewModel.loginViewModel = loginViewModel

        let keychain = KeychainSwift()
        if let token = keychain.get("userToken"), !TokenHelper.isTokenExpired(token: token) {
            self.loginViewModel.viewState = .home
        }
    }



    var body: some View {
        switch loginViewModel.viewState {
        case .username:
            UsernameView(viewModel: loginViewModel)
        case .password:
            PasswordView(viewModel: loginViewModel)
        case .signUp:
            SignUpView(viewModel: signUpViewModel)
        case .home:
            HomeView()
        }
    }
}







extension View {
    func flexible() -> some View {
        self.layoutPriority(1)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


