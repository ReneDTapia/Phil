//
//  CategoriesSection.swift
//  Phil
//
//  Created on 21/03/24.
//

import SwiftUI

struct CategoriesSection: View {
    var categories: [Category]

    @StateObject var categoryVM = CategoryViewModel()
    
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Categories")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            // Grid of categories
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(categoryVM.resultCategories) { category in
                    NavigationLink(destination: CategoryDetailView(categoryId: category.id, categoryTitle: category.name)) {
                        CategoryCard(
                            title: category.name,
                            emoji: category.emoji ?? "📚",
                            backgroundColor: Color(category.color ?? "#FFFFFF")
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
                Category(id: 1, title: "Anxiety", emoji: "🧠", color: Color.pink.opacity(0.3)),
                Category(id: 2, title: "Depression", emoji: "💙", color: Color.blue.opacity(0.3)),
                Category(id: 3, title: "Sleep", emoji: "😴", color: Color.cyan.opacity(0.3))
            ]
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
} 
