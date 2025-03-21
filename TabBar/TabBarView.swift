//
//  TabBarView.swift
//  Phil
//
//  Created by Rene  on 06/11/23.
//

import Foundation
import SwiftUI

// No necesitamos importar Doctors y Explore ya que están en el mismo proyecto

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
            Color(.systemGray6)
            
            VStack(alignment: .leading) {
                TabView(selection: $selectedTab) {
                    // Home tab view
                    ContentsView(user:TokenHelper.getUserID() ?? 0)
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                        .tag(0)
                    
                    // Explore tab view
                    ExploreView()
                        .tabItem {
                            Label("Explore", systemImage: "magnifyingglass")
                        }
                        .tag(1)
                    
                    // Doctors tab view
                    DoctorsMainView()
                        .tabItem {
                            Label("Specialists", systemImage: "heart.text.square")
                        }
                        .tag(2)
                    
                    // Chats tab view
                    MyChatsView(userId: TokenHelper.getUserID() ?? 0)
                        .tabItem {
                            Label("Chats", systemImage: "message")
                        }
                        .tag(3)
                    
                    // Settings tab view
                    Config()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape")
                        }
                        .tag(4)
                }
                .accentColor(.indigo)
            }
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView(user: 1)
    }
}
