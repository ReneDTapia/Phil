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

    init() {
        // Customize the appearance of the Tab Bar
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black

        // Set the tab bar item appearance for both selected and unselected states

       
 
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]

        // Set the shadow image to a thin white line and the shadow color to transparent
        appearance.shadowImage = UIImage() // Creates an empty image
        appearance.shadowColor = .white
        // Apply the appearance to the UITabBar
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance // For when the TabBar is scrolled
    }

   
    var body: some View {
            TabView(selection: $selectedTab) { // Usar el binding al estado para la selección
                // First tab view
                ContentsView()
                    .tabItem {
                        Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                            .environment(\.symbolVariants, .none)
                        
                    }
                    .tag(0) // Asignar un tag a cada pestaña
                    .background(Color.black)

                // Continue with other tabs...
                PictureView()
                    .tabItem {
                        Image(systemName: selectedTab == 1 ? "calendar" : "calendar")
                            .environment(\.symbolVariants, .none)
                    }
                    .tag(1)
                    .background(Color.black)
                
                // Special tab with a larger 'plus.circle' icon
                PictureView()
                    .tabItem {
                        Image(systemName: selectedTab == 2 ? "plus.circle.fill" : "plus.circle")
                            .environment(\.symbolVariants, .none)
                    }
                    .tag(2)
                    .background(Color.black)

                MyChatsView(userId: 1)
                    .tabItem {
                        Image(systemName: selectedTab == 3 ? "message.fill" : "message")
                            .environment(\.symbolVariants, .none)
                    }
                    .tag(3)
                    .background(Color.black)

                // Second tab view
                InitialFormView()
                    .tabItem {
                        Image(systemName: selectedTab == 4 ? "person.fill" : "person")
                            .environment(\.symbolVariants, .none)
                    }
                    .tag(4)
                    .background(Color.black)
            }
            .accentColor(Color(hex: "6b6eab"))
        }
    }

    struct TabBarView_Previews: PreviewProvider {
        static var previews: some View {
            TabBarView()
        }
    }
