//
//  CategoryCard.swift
//  Phil
//
//  Created on 21/03/24.
//

import SwiftUI

struct CategoryCard: View {
    // MARK: - Properties
    var title: String
    var emoji: String
    var backgroundColor: Color
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 20)
                .fill(backgroundColor)
                .aspectRatio(1, contentMode: .fit)
            
            // Content
            VStack(spacing: 10) {
                Text(emoji)
                    .font(.system(size: 40))
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
            }
        }
    }
}

// MARK: - Preview
struct CategoryCard_Previews: PreviewProvider {
    static var previews: some View {
        CategoryCard(
            title: "Anxiety",
            emoji: "🧠",
            backgroundColor: Color.pink.opacity(0.3)
        )
        .frame(width: 100, height: 100)
        .previewLayout(.sizeThatFits)
    }
} 
