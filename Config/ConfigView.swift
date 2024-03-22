//
//  ConfigView.swift
//  Phil
//
//  Created by alumno on 21/03/24.
//

import Foundation
import SwiftUI

struct Config: View {
    
    @StateObject var LoginVM = LoginViewModel()
    @State private var showUserView = false
    var body: some View {
        NavigationStack{
            VStack{
                HStack{
                    Text("Configuración")
                        .font(.title)
                        .bold()
                    Spacer()
                }
                .padding(25)
                
                
                HStack{
                    HStack{
                        Image(systemName: "person.fill")
                            .foregroundColor(.indigo)
                        NavigationLink(destination: UserView(userId: TokenHelper.getUserID() ?? 0)){
                            Text("Perfil")
                                .foregroundColor(.indigo)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                HStack{
                    HStack{
                        Image(systemName: "star.fill")
                            .foregroundColor(.indigo)
                        NavigationLink(destination: InitialFormView(userId: TokenHelper.getUserID() ?? 0)){
                            Text("Cuestionario Inicial")
                                .foregroundColor(.indigo)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                Button(action: {
                    LoginVM.logout()
                    LoginVM.viewState = .username
                    self.showUserView = true
                    UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: MainView())
                }) {
                    HStack{
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.indigo)
                        Text("Salir")
                            .foregroundColor(.indigo)
                        Spacer()
                    }
                    .foregroundColor(.black)
                    .padding()
                    
                }
                Spacer()
            }
            
        }
    }
}

struct Config_Previews: PreviewProvider {
    static var previews: some View {
        Config()
    }
}
