//
//  CategoryVIew.swift
//  Phil
//
//  Created by Dario on 22/03/25.
//

import SwiftUI
import Foundation

struct CategoryView: View {
    let user: Int
    
    @StateObject var categoryVM = CategoryViewModel()
    @State private var isLoading = true
    @State private var messageLoad = "Cargando..."
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack(alignment: .leading) {
                    Color.white.edgesIgnoringSafeArea(.all)
                    
                    VStack(alignment: .leading) {
                        HStack{
                            Text("Categorías")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding()
                        
                        if categoryVM.isLoading {
                            Spacer()
                            ProgressView(messageLoad)
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(width: geometry.size.width)
                                .scaleEffect(1.5)
                            Spacer()
                        } else if let errorMessage = categoryVM.errorMessage {
                            Spacer()
                            Text(errorMessage)
                                .frame(width: geometry.size.width)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding()
                            Spacer()
                        } else if categoryVM.resultCategories.isEmpty {
                            Spacer()
                            Text("No hay categorías disponibles")
                                .frame(width: geometry.size.width)
                                .foregroundColor(.secondary)
                            Spacer()
                        } else {
                            // Content view when loaded
                            VStack(alignment: .leading, spacing: 8){
                                Text("Todas las categorías")
                                    .font(.title2)
                                    .bold()
                                    .padding(.horizontal, 16)
                                    .padding(.top, 8)
                                    .foregroundColor(.primary)
                                
                                ScrollView {
                                    LazyVStack(spacing: 16) {
                                        ForEach(categoryVM.resultCategories) { category in
                                            NavigationLink(destination: CategoryDetailView(
                                                categoryId: category.id,
                                                categoryTitle: category.name
                                            )) {
                                                CategoryCardView(
                                                    name: category.name,
                                                    emoji: category.emoji ?? "📋",
                                                    color: category.color ?? "#6C63FF"
                                                )
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .padding(.bottom, 16)
                                }
                                .background(Color.white)
                            }
                            .background(Color.white)
                        }
                    }
                }
                .background(Color.white)
            }
            .onAppear{
                Task{
                    await categoryVM.getCategories()
                }
            }
            .background(Color.white)
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }
}

// Category card component
struct CategoryCardView: View {
    let name: String
    let emoji: String
    let color: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Emoji circle
            ZStack {
                Circle()
                    .fill(Color(hex: color))
                    .frame(width: 60, height: 60)
                
                Text(emoji)
                    .font(.system(size: 30))
            }
            
            // Category name
            Text(name)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            
            Spacer()
            
            // Arrow
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
        .padding(.horizontal, 16)
    }
}


// MARK: - Preview
struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView(user: 1)
    }
}
