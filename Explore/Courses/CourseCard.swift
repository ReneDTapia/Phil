//
//  CourseCard.swift
//  Phil
//
//  Created on 21/03/24.
//

import SwiftUI

struct CourseCard: View {
    // MARK: - Properties
    var title: String
    var lessons: Int
    var imageUrl: String?
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            courseImageView
            courseInfoView
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Course Image View
    private var courseImageView: some View {
        ZStack(alignment: .bottomLeading) {
            // Background gradient
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.7)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .aspectRatio(16/9, contentMode: .fill)
                .overlay(courseImageContent)
            
            // Title
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding([.horizontal, .bottom], 16)
        }
    }
    
    // MARK: - Course Image Content
    @ViewBuilder
    private var courseImageContent: some View {
        if let imageUrl = imageUrl, !imageUrl.isEmpty {
            // Si hay una URL de imagen, intentar cargarla
            AsyncImage(url: URL(string: imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    placeholderImage
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            // Si no hay URL, mostrar un placeholder
            placeholderImage
        }
    }
    
    // MARK: - Placeholder Image
    private var placeholderImage: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .foregroundColor(.gray.opacity(0.5))
    }
    
    // MARK: - Course Info View
    private var courseInfoView: some View {
        HStack {
            // Lessons count
            HStack(spacing: 4) {
                Image(systemName: "book")
                    .font(.subheadline)
                Text("\(lessons) lessons")
                    .font(.subheadline)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .foregroundColor(.black)
    }
}

// MARK: - Preview
struct CourseCard_Previews: PreviewProvider {
    static var previews: some View {
        CourseCard(
            title: "Overcoming Social Anxiety",
            lessons: 8,
            imageUrl: nil
        )
        .frame(width: 300)
        .previewLayout(.sizeThatFits)
        .padding()
    }
} 
