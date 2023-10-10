//
//  SignUpView.swift
//  Phil
//
//  Created by Rene  on 04/10/23.
//

import Foundation
import SwiftUI

struct SignUpView: View {
    @ObservedObject var viewModel: SignUpViewModel
    @Environment(\.colorScheme) var colorScheme
    


    var body: some View {
        
        let backgroundColor = colorScheme == .dark ? Color.black : Color.white
        let textColor = colorScheme == .dark ? Color.white : Color.black
        let buttonColor = Color(red: 0.42, green: 0.43, blue: 0.67)
        
       
        VStack(spacing: 20) {
            
            
            
            ZStack {
                HStack {
                    // The 'Go Back' button
                    Button(action: {
                        self.viewModel.loginViewModel?.viewState = .username
                      
                    }) {
                        Image(systemName: "chevron.left")
                            .font(Font.system(size: 20, weight: .bold))
                            .foregroundColor(textColor)
                    }
                    .padding(.leading, 20)
                    .padding(.top)
                    
                    Spacer() // This ensures the button stays left-aligned
                }

                // Phil text (centered by virtue of being in a ZStack)
                Text("Phil")
                    .font(.custom("Montserrat-Bold", size: 30))
                    .padding(.top)
                    .foregroundColor(textColor)
            
            }
            .padding(.bottom, 30) // You can adjust this padding as necessary
            
                
                VStack(spacing: 5) {
                    Image("logo_placeholder")
                        .resizable()
                        .frame(width: 64, height: 64)
                        .padding(.bottom, 20)
                    
                    Text("Create your account!")
                                    .font(.custom("Montserrat Regular", size: 30))
                                    .foregroundColor(textColor)
                                    .multilineTextAlignment(.center)
                }
            
            
            // Input Fields
                       inputField(title: "Email", text: $viewModel.user.email)
                       inputField(title: "Username", text: $viewModel.user.username)
                       inputField(title: "Password", text: $viewModel.user.password, isSecure: true)
                       inputField(title: "Confirm Password", text: $viewModel.user.confirmPassword, isSecure: true)
                     
            
            Toggle(isOn: $viewModel.isDeaf) {
                Text("I am deaf")
                    .font(.custom("Montserrat-Regular", size: 15))
                    .foregroundColor(textColor)
            }
            .padding(.top, 20)

            // Sign Up Button
            Button(action: {self.viewModel.register()}) {
                Text("Sign Up")
                    .font(Font.custom("Montserrat-Bold", size: 15).weight(.bold))
                    .foregroundColor(.white)
                    .frame(width: 284, height: 47)
                    .background(buttonColor)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .background(backgroundColor)
        .alert(isPresented: $viewModel.showAlert) { // Añade esto aquí
                Alert(title: Text("Error"),
                      message: Text(viewModel.alertMessage),
                      dismissButton: .default(Text("OK")))
            }
    }

    func inputField(title: String, text: Binding<String>, isSecure: Bool = false) -> some View {
        let placeholderColor = colorScheme == .dark ? Color.white : Color.gray
        let textColor = colorScheme == .dark ? Color.white : Color(red: 0.42, green: 0.43, blue: 0.67)
        let buttonColor = colorScheme == .dark ? Color.black : Color.white
        let borderColor = Color(red: 0.42, green: 0.43, blue: 0.67)
        
        return ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 57.29)
                .fill(buttonColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 57.29)
                        .stroke(borderColor, lineWidth: 0.994)
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



}

public struct PlaceholderStyle: ViewModifier {
    var showPlaceHolder: Bool
    var placeholder: String
    var color: Color

    public func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceHolder {
                Text(placeholder)
                    .foregroundColor(color)
                    .padding(.leading, 0)
            }
            content
        }
    }
}


struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(viewModel: SignUpViewModel())
    }
}







