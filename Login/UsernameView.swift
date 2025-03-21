//
//  UsernameView.swift
//  Phil
//
//  Created by Pingli  on 04/10/23.
//

import SwiftUI

struct UsernameView: View {

    @ObservedObject var viewModel: LoginViewModel
    @Environment(\.colorScheme) var colorScheme
//    @State private var showUsernameView = false

    
    var body: some View {
        VStack(spacing: 20) {
            VStack{
                Text("¡Bienvenido de nuevo!")
                    .font(.title)
                    .bold()
                Text("Estamos emocionados de tenerte de vuelta")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            VStack(spacing: 20) {
            }
            
            Image("chiriwilla")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            
            TextField("Usuario o correo electrónico", text: $viewModel.user.username)
                                .padding()
                                .background(Color(.systemBackground).cornerRadius(0))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15).stroke(style:StrokeStyle())

                                )
                                .padding()
          
            
            HStack {
                // Continue Button
                Button(action: {
                    // Print username for debugging
                    print("Username/Email entered by user: \(viewModel.user.username)")
                    self.viewModel.viewState = .password // Cambia a la vista de contraseña
                        
                }) {
                    Text("Continuar")
                        .font(.headline)
                        .bold()
                        .foregroundColor(Color.white)
                        .frame(minWidth: 300)
                        .cornerRadius(100)
                    
                    
                }
                .padding()
                .background(Color.indigo)
                .cornerRadius(100)
            }
          
            
            
            // Connect Using
            






            
//            HStack{
//                                VStack{
//                                    Divider()
//                                }
//                                Text("Próximamente")
//                                VStack{
//                                    Divider()
//                                }
//                            }
//
//                            Button(action:{
//                                print("Botón presionado")
//                            }){
//                                Text("Continuar con Google")
//                                    .padding()
//                                    .frame(minWidth: 300)
//                                    .bold()
//                                    .font(.title3)
//                                    .foregroundColor(colorScheme == .dark ? .white : .gray)
//                                    .background(colorScheme == .dark ? .gray.opacity(0.3) : .white)
//                                    .cornerRadius(10)
//                                    .shadow(radius: 3,x:0,y:3)
//                            }
//                            .padding(.bottom,10)
//
//                            Button(action:{
//                                print("Botón presionado")
//                            }){
//                                Text("Continuar con Apple")
//                                    .padding()
//                                    .frame(minWidth: 300)
//                                    .bold()
//                                    .font(.title3)
//                                    .foregroundColor(colorScheme == .dark ? .black : .white)
//                                    .background(colorScheme == .dark ? .white : .black)
//                                    .cornerRadius(10)
//                                    .shadow(radius: 3,x:0,y:3)
//                            }
                            HStack{
                                Text("¿No tienes una cuenta?")
                                    .font(.callout)
                                Button(action:{ self.viewModel.viewState = .signUp}){
                                    Text("Registrate ahora")
                                                                .foregroundColor(.indigo)
                                                                .bold()
                                                                .font(.callout)
                                }
                            }
                            .padding()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 40)
//                        .onAppear{
//                            viewModel.logout() // god dice el BienAndroid
//                        }
    }
            
    
    
    // Helper function for Input Fields
    func inputField(title: String, text: Binding<String>, isSecure: Bool = false) -> some View {
            let borderColor = Color(red: 0.42, green: 0.43, blue: 0.67)
            
            return Group {
                if isSecure {
                    SecureField(title, text: text)
                } else {
                    TextField(title, text: text)
                }
            }
            .padding()
            .background(Color.white.cornerRadius(0))
            .overlay(
                RoundedRectangle(cornerRadius: 15).stroke(borderColor)
            )
            .padding(.horizontal, 20)
        }

    
    
    // Helper function for Social Icons
    func socialIcon(name: String) -> some View {
        Image(name)
            .resizable()
            .frame(width: 54, height: 54)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
   
}



struct UsernameView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
