//
//  TabBarView.swift
//  Phil
//
//  Created by Rene  on 06/11/23.
//

import Foundation
import SwiftUI

struct TabBarView: View {
    
    @State private var selectedTab: Int = 0 // Agregar una propiedad de estado para rastrear la pestaña seleccionada
  
    @StateObject var VM = LoginViewModel()
    @State private var showMenu = false
    
    let user : Int
    
    init(user : Int) {
        self.user = user
        // Customize the appearance of the Tab Bar
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        
        
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance // For when the TabBar is scrolled
    }
    
    
    var body: some View {
        ZStack(alignment: .leading) {
            Color.black
                .ignoresSafeArea(.all)
            
            VStack(alignment: .leading) {
                                TabView(selection: $selectedTab) { // Usar el binding al estado para la selección
                    // First tab view
                    ContentsView(user:TokenHelper.getUserID() ?? 0)
                        .tabItem {
                            Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                                .environment(\.symbolVariants, .none)
                            
                        }
                        .tag(0) // Asignar un tag a cada pestaña
                        .background(Color.black)
                   
                    
                    MyChatsView(userId: TokenHelper.getUserID() ?? 0)
                        .tabItem {
                            Image(systemName: selectedTab == 1 ? "message.fill" : "message")
                                .environment(\.symbolVariants, .none)
                        }
                        .tag(1)
                        .background(Color.black)
                    
                    InitialFormView(userId: TokenHelper.getUserID() ?? 0)
                        .tabItem {
                            Image(systemName: selectedTab == 2 ? "person.fill" : "person")
                                .environment(\.symbolVariants, .none)
                        }
                        .tag(2)
                    
                   
                }
                .accentColor(Color(hex: "6b6eab"))
                
            }
            
            if showMenu{
                ZStack{
                    Color(.black)
                }
                .opacity(0.5)
                .onTapGesture {
                    withAnimation{
                        showMenu = false
                    }
                    
                }
            }
            
            HStack{
                Menu(showMenu: $showMenu, LoginVM: VM, user: user )
                    .offset(x:showMenu ? 0 : UIScreen.main.bounds.width * -1, y:0)
                    .frame(width: 300, height:.infinity)
                    .ignoresSafeArea(.all)
                
            }
        }
    }
}
    struct TabBarView_Previews: PreviewProvider {
        static var previews: some View {
            TabBarView(user: 1)
        }
    }
