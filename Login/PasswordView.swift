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
    

    var body: some View {
        
        let backgroundColor = colorScheme == .dark ? Color.black : Color.white
        let textColor = colorScheme == .dark ? Color.white : Color.black
        let lineColor = colorScheme == .dark ? Color.white : Color.black
//        if viewModel.isLoggedIn{
//            TabBarView(user: 37)
//        }


        return VStack(spacing: 20) {
            ZStack {
                HStack {
                    Button(action: {
                        self.viewModel.viewState = .username
                    }) {
                        Image(systemName: "chevron.left")
                            .font(Font.system(size: 20, weight: .bold))
                            .foregroundColor(textColor)
                    }
                    .padding(.leading, 20)
                    .padding(.top)
                    
                    Spacer()
                }

                Text("Phil")
                    .font(.custom("Montserrat-Bold", size: 30))
                    .foregroundColor(textColor)
                    .padding(.top)
            }
            .padding(.bottom, 30)

            VStack(spacing: 5) {
                Image("logo_placeholder")
                    .resizable()
                    .frame(width: 64, height: 64)
                    .padding(.bottom, 20)
                
                Text("Hi, \(viewModel.user.username)!")
                    .font(.custom("Montserrat Regular", size: 30))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)
            }
            
            
            // Input Field
            inputField(title: "Password", text: $viewModel.user.password, isSecure: true)
            
            // Sign In Button
            Button(action: {self.viewModel.login()}) {
                Text("Sign In")
                    .font(Font.custom("Montserrat-Bold", size: 15).weight(.bold))
                    .foregroundColor(Color(red: 0.96, green: 0.96, blue: 1))
                    // center horizontally without affecting the arrow
                    .padding(.leading, 100)
    
                Spacer()
    
            }
            .padding(15)
            .frame(width: 284, height: 47)
            .background(Color(red: 0.42, green: 0.43, blue: 0.67))
            .cornerRadius(10)
            
            // Connect Using
            HStack {
                Spacer()
                
                Rectangle()
                    .fill(lineColor) // Color de la línea
                    .frame(width: 70, height: 0.5) // Controla el ancho de la línea aquí
                
        
                Text("OR CONNECT USING:")
                                    .font(Font.custom("Montserrat-Bold", size: 15).weight(.bold))
                                    .foregroundColor(textColor)
                                    .background(Color.clear)
                                    .padding(.horizontal, 5)

                                Rectangle()
                                    .fill(lineColor)
                                    .frame(width: 70, height: 0.5)
                Spacer()
            }
            .padding(.top, 10)







            
            // Social Media Icons
            HStack(spacing: 15) {
                socialIcon(name: "apple_logo")
                socialIcon(name: "google_logo")
                socialIcon(name: "facebook_logo")
            }
          
            
            // Account Details
            VStack(spacing: 5) {
                Text("Don’t have an account yet?")
                                    .font(Font.custom("Montserrat-Regular", size: 15))
                                    .foregroundColor(textColor)

                                Button(action: {
                                    self.viewModel.viewState = .signUp
                                }) {
                                    Text("Sign Up")
                                        .font(Font.custom("Montserrat-Bold", size: 15).weight(.bold))
                                        .underline()
                                        .foregroundColor(textColor)
                                }
                            }
                            .padding(.top, 70)

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
               .background(backgroundColor)
               .padding(.horizontal, 20)
           }
            
       
   
    func inputField(title: String, text: Binding<String>, isSecure: Bool = false) -> some View {
            let placeholderColor = colorScheme == .dark ? Color.white : Color.gray
            let textColor = colorScheme == .dark ? Color.white : Color(red: 0.42, green: 0.43, blue: 0.67)
            let buttonColor = colorScheme == .dark ? Color.black : Color.white

            return ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 57.29)
                    .fill(buttonColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 57.29)
                            .stroke(Color(red: 0.42, green: 0.43, blue: 0.67), lineWidth: 0.994)
                    )
                
                if isSecure {
                    SecureField("", text: text)
                        .modifier(PlaceholderStyle(showPlaceHolder: text.wrappedValue.isEmpty,
                                                   placeholder: title,
                                                   color: placeholderColor))
                        .font(.custom("Roboto-Light", size: 15))
                        .foregroundColor(textColor)
                        .padding(.leading, 25)
                } else {
                    TextField("", text: text)
                        .modifier(PlaceholderStyle(showPlaceHolder: text.wrappedValue.isEmpty,
                                                   placeholder: title,
                                                   color: placeholderColor))
                        .font(.custom("Roboto-Light", size: 15))
                        .foregroundColor(textColor)
                        .padding(.leading, 25)
                }
            }
            .frame(width: 284, height: 47)
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


