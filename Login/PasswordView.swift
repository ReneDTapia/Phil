//
//  PasswordView.swift
//  Phil
//
//  Created by Rene  on 04/10/23.
//


import SwiftUI

struct PasswordView: View {
    @ObservedObject var viewModel: LoginViewModel
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var isFocused: Bool
    

    var body: some View {


        VStack(spacing: 20) {
            
                HStack {
                    Button(action: {
                        self.viewModel.viewState = .username
                    }) {
                        HStack{
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

                VStack{
                    Text("Ingresa la contraseña")
                        .font(.title)
                        .bold()
                    Text("para \(viewModel.user.username)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            
                .onAppear{isFocused = true}
                .padding(.top,20)
                    
            
            
            SecureField("Contraseña", text: $viewModel.user.password)
                .padding()
                .background(Color(.systemBackground).cornerRadius(0))
                .overlay(RoundedRectangle(cornerRadius: 15).stroke())
                .padding()
                .padding(.horizontal,20)
                .focused($isFocused)
            
                
            // Sign In Button
            Button(action: {self.viewModel.login()}) {
                Text("Iniciar Sesión")
                    .padding()
                    .frame(minWidth: 300)
                    .bold()
                    .font(.title3)
                    .foregroundColor(.white)
                    .background(Color.indigo)
                    .cornerRadius(100)
                    
    
            }
            
                            Spacer()
                        }
        
        .alert(isPresented: $viewModel.showAlert) {
                   Alert(title: Text("Error"),
                         message: Text(viewModel.alertMessage),
                         dismissButton: .default(Text("OK")) {
                             viewModel.showAlert = false
                         }
                   )
               }
               .padding(.horizontal, 20)
               .gesture(
                   DragGesture()
                       .onEnded { gesture in
                           if gesture.translation.width > 100 {
                               self.viewModel.viewState = .username
                           }
                       }
               )
           }
    
            
       
   
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
            .background(Color(.systemBackground).cornerRadius(0))
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

struct PasswordView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
