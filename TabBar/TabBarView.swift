//
//  TabBarView.swift
//  Phil
//
//  Created by Rene  on 06/11/23.
//

import Foundation
import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            // Aquí pones la primera vista/tab que quieres mostrar
            ContentsView()
                .tabItem {
                    Label("Contenidos", systemImage: "star.fill")
                }

            // Aquí pones la segunda vista/tab
            InitialFormView()
                .tabItem {
                    Label("Tu", systemImage: "person.fill")
                }

            // Continúa con las demás vistas que necesitas en tu TabView
            PictureView()
                .tabItem {
                    Label("Tus Fotos", systemImage: "photo.fill")
                }

            MyChatsView(userId: 1) // Asume que esta vista ya existe y puede tomar un `userId`
                .tabItem {
                    Label("Chat", systemImage: "message")
                }

            // ... puedes agregar más tabs según necesites ...
        }
    
        
    
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
