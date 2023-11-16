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
    @StateObject private var cameraViewModel = CameraViewController()
    
    let user : Int
    
    init(user : Int) {
        self.user = user
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
        ZStack(alignment: .leading) {
            Color.black
                .ignoresSafeArea(.all)
            
            VStack(alignment: .leading) {
                HStack {
                    // Botón del menú
                    Button(action: {
                        withAnimation {
                            self.showMenu.toggle()
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    
                    Text(String(TokenHelper.getUserID() ?? 0))
                            .foregroundColor(.white)
                    Spacer()
                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50)
                }
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 1, trailing: 10))
                TabView(selection: $selectedTab) { // Usar el binding al estado para la selección
                    // First tab view
                    ContentsView(user:TokenHelper.getUserID() ?? 0)
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
                    ModeloView()
                        .tabItem {
                            Image(systemName: selectedTab == 2 ? "plus.circle.fill" : "plus.circle")
                                .environment(\.symbolVariants, .none)
                        }
                        .tag(2)
                        .background(Color.black)
                    
                    MyChatsView(userId: TokenHelper.getUserID() ?? 0)
                        .tabItem {
                            Image(systemName: selectedTab == 3 ? "message.fill" : "message")
                                .environment(\.symbolVariants, .none)
                        }
                        .tag(3)
                        .background(Color.black)
                    
                    // Second tab view
                    AnalyticsView()
                        .tabItem {
                            Image(systemName: selectedTab == 4 ? "chart.bar.fill" : "chart.bar")
                                .environment(\.symbolVariants, .none)
                        }
                        .tag(4)
                        .background(Color.black)
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
