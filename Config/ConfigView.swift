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
    @Environment(\.colorScheme) var colorScheme
    @State private var showUserView = false
    var body: some View {
        NavigationStack{
            ZStack{
                Color(colorScheme == .dark ? .black : .systemGray6)
                    .ignoresSafeArea()
                VStack{
                    HStack{
                        Text("Configuración")
                            .font(.largeTitle)
                            .bold()
                        Spacer()
                    }
                    .padding(25)
                    
                    List{
                        HStack{
                            HStack{
                                Image(systemName: "person")
                                NavigationLink(destination: UserView(userId: TokenHelper.getUserID() ?? 0)){
                                    Text("Perfil")
                                }
                                .navigationBarBackButtonHidden(true)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical)
                        HStack{
                            HStack{
                                Image(systemName: "list.clipboard")
                                NavigationLink(destination: InitialFormView(userId: TokenHelper.getUserID() ?? 0)){
                                    Text("Cuestionario Inicial")
                                        
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical)
                        
                        
                    }
                    .frame( height: 200)
                    
                    
                    List{
                        Button(action: {
                            LoginVM.logout()
                            LoginVM.viewState = .username
                            self.showUserView = true
                            UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: MainView())
                        }) {
                            HStack{
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.red)
                                Text("Salir")
                                    .foregroundColor(.red)
                                Spacer()
                            }
                            .padding(.vertical)
                            
                        }
                    }
                    .padding(.top,-10)
                }
                
            }
        }
    }
}

struct Config_Previews: PreviewProvider {
    static var previews: some View {
        Config()
    }
}
