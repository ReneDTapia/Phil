//
//  SignUpView.swift
//  Phil
//
//  Created by Rene  on 04/10/23.
//

//
//  SignUpView.swift
//  Phil
//
//  Created by Rene  on 04/10/23.
//

import SwiftUI

struct SignUpView: View {
    @ObservedObject var viewModel: SignUpViewModel
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var isFocused: Bool

    var body: some View {
        let backgroundColor = colorScheme == .dark ? Color.black : Color.white
        let textColor = colorScheme == .dark ? Color.white : Color.black
        let buttonColor = Color(.systemIndigo)

        
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    Button(action: {
                        self.viewModel.loginViewModel?.viewState = .username
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.indigo)
                            
                            Text("Regresar")
                                .font(.caption)
                                .foregroundColor(.indigo)
                        
                        }
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                }
                
                VStack {
                    Text("Crea tu cuenta")
                        .font(.title)
                        .bold()
                        .foregroundColor(textColor)
                    
                    Text("Estas a un solo paso de empezar")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)

                TextField("Usuario", text: $viewModel.user.username)
                    .padding()
                    .background(Color(.systemBackground).cornerRadius(0))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15).stroke(Color.gray)
                    )
                    .padding(.horizontal, 20)
                    .focused($isFocused)

                TextField("Correo electrónico", text: $viewModel.user.email)
                    .padding()
                    .background(Color(.systemBackground).cornerRadius(0))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15).stroke(Color.gray)
                    )
                    .padding(.horizontal, 20)

                SecureField("Contraseña", text: $viewModel.user.password)
                    .padding()
                    .background(Color(.systemBackground).cornerRadius(0))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15).stroke(Color.gray)
                    )
                    .padding(.horizontal, 20)

                SecureField("Confirmar Contraseña", text: $viewModel.user.confirmPassword)
                    .padding()
                    .background(Color(.systemBackground).cornerRadius(0))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15).stroke(Color.gray)
                    )
                    .padding(.horizontal, 20)

                Toggle(isOn: $viewModel.isDeaf) {
                    Text("¿Tengo discapacidades auditivas?")
                        .font(.body)
                        .foregroundColor(textColor)
                }
                .padding(.top, 20)

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.viewModel.isButtonPressed = true
                    }

                    self.viewModel.register()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.viewModel.isButtonPressed = false
                        }
                    }
                }) {
                    Text("Crear cuenta")
                        .padding()
                        .frame(minWidth: 300)
                        .bold()
                        .font(.title3)
                        .foregroundColor(.white)
                        .background(viewModel.isButtonPressed ? buttonColor.opacity(0.7) : buttonColor)
                        .cornerRadius(100)
                }
                
                Spacer()
            }
            .padding()
            .background(backgroundColor)
            .onAppear {
                isFocused = true
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Error"),
                      message: Text(viewModel.alertMessage),
                      dismissButton: .default(Text("Acepto")))
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(viewModel: SignUpViewModel())
    }
}


