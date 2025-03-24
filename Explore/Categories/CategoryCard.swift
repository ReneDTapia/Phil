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
    var emoji: String?
    var backgroundColor: Color
    
    // Computed property to handle emoji or use default
    private var displayEmoji: String {
        if let emoji = emoji, !emoji.isEmpty {
            return emoji
        } else {
            // Return a default emoji based on category title (both English and Spanish)
            let lowerTitle = title.lowercased()
            switch true {
            case lowerTitle.contains("anxiety") || lowerTitle.contains("ansiedad"):
                return "🧠"
            case lowerTitle.contains("depression") || lowerTitle.contains("depresión") || lowerTitle.contains("depresion"):
                return "💙"
            case lowerTitle.contains("stress") || lowerTitle.contains("estrés") || lowerTitle.contains("estres"):
                return "😓"
            case lowerTitle.contains("sleep") || lowerTitle.contains("sueño"):
                return "😴"
            case lowerTitle.contains("relationship") || lowerTitle.contains("relacion") || lowerTitle.contains("relación"):
                return "❤️"
            case lowerTitle.contains("esteem") || lowerTitle.contains("autoestima"):
                return "🌟"
            default:
                return "✦"
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 20)
                .fill(backgroundColor)
                .aspectRatio(1, contentMode: .fit)
            
            // Content
            VStack(spacing: 10) {
                Text(displayEmoji)
                    .font(.system(size: 40))
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 4)
            }
        }
        .onAppear {
            print("📱 Rendering category: \(title), emoji: \(emoji ?? "nil")")
        }
    }
}

// MARK: - Preview
struct CategoryCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CategoryCard(
                title: "Anxiety",
                emoji: "🧠",
                backgroundColor: Color.pink.opacity(0.3)
            )
            
            CategoryCard(
                title: "Depression",
                emoji: nil,
                backgroundColor: Color.blue.opacity(0.3)
            )
        }
        .frame(width: 100, height: 100)
        .previewLayout(.sizeThatFits)
    }
} 
