//
//  ContentView.swift
//  Phil
//
//  Created by Rene  on 03/10/23.
//

import SwiftUI


struct ContentView: View {
    @ObservedObject var loginViewModel = LoginViewModel()
    @ObservedObject var signUpViewModel = SignUpViewModel()  // Creamos una instancia de SignUpViewModel aquí
    
    init() {
        signUpViewModel.loginViewModel = loginViewModel
    }
    
    var body: some View {
        switch loginViewModel.viewState {
        case .username:
            UsernameView(viewModel: loginViewModel)
        case .password:
            PasswordView(viewModel: loginViewModel)
        case .signUp:
            SignUpView(viewModel: signUpViewModel) // Usamos la instancia creada anteriormente
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


