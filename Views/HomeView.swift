//
//  HomeView.swift
//  Phil
//
//  Created by Rene  on 05/10/23.
//

import Foundation
import SwiftUI

struct HomeView: View {

    var body: some View {
        VStack {
            Text("Welcome to Home!")
                .font(.largeTitle)
                .padding()

            Button(action: {
                AuthService.shared.logout()
            }) {
                Text("Logout")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 60)
                    .background(Color.blue)
                    .cornerRadius(15)
            
            }
        }
    }
}
