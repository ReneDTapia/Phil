//
//  CategoriesSection.swift
//  Phil
//
//  Created on 21/03/24.
//

import SwiftUI

struct CategoriesSection: View {
    var categories: [Category]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Categorías")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            // Grid of categories
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(categories) { category in
                    NavigationLink(destination: CategoryDetailView(categoryId: category.id, categoryTitle: category.title)) {
                        CategoryCard(
                            title: category.title,
                            emoji: category.emoji,
                            backgroundColor: category.color
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CategoriesSection_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesSection(
            categories: [
                Category(id: "anxiety", title: "Ansiedad", emoji: "🧠", color: Color.pink.opacity(0.3)),
                Category(id: "depression", title: "Depresión", emoji: "💙", color: Color.blue.opacity(0.3)),
                Category(id: "sleep", title: "Sueño", emoji: "😴", color: Color.cyan.opacity(0.3))
            ]
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
} 
