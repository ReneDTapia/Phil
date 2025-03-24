//
//  CourseDetailView.swift
//  Phil
//
//  Created on 16/03/24.
//

import SwiftUI

struct CourseDetailView: View {
    // MARK: - Properties
    let course: Course
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                courseImageView
                courseDetailsView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Course Image View
    private var courseImageView: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .aspectRatio(16/9, contentMode: .fill)
            .overlay(courseImageContent)
    }
    
    // MARK: - Course Image Content
    @ViewBuilder
    private var courseImageContent: some View {
        if let imageUrl = course.imageUrl, !imageUrl.isEmpty {
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
            .frame(width: 60, height: 60)
            .foregroundColor(.gray.opacity(0.5))
    }
    
    // MARK: - Course Details View
    private var courseDetailsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text(course.title)
                .font(.title)
                .fontWeight(.bold)
            
            // Lessons and duration
            courseMetadataView
                .padding(.vertical, 8)
            
            // Description
            Text("About this course")
                .font(.headline)
                .padding(.top, 8)
            
            Text(course.description)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Enroll button
            enrollButton
                .padding(.top, 20)
        }
        .padding()
    }
    
    // MARK: - Course Metadata View
    private var courseMetadataView: some View {
        HStack {
            Image(systemName: "book.closed")
                .foregroundColor(.indigo)
            Text("\(course.lessons) lessons")
                .foregroundColor(.indigo)
            
            Spacer()
            
            Image(systemName: "clock")
                .foregroundColor(.indigo)
            Text(course.duration)
                .foregroundColor(.indigo)
        }
    }
    
    // MARK: - Enroll Button
    private var enrollButton: some View {
        Button(action: {
            // Enroll action
        }) {
            Text("Enroll Now")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.indigo)
                .cornerRadius(12)
        }
    }
}

// MARK: - Preview
struct CourseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CourseDetailView(
                course: Course(
                    id: "1",
                    title: "SwiftUI Essentials",
                    description: "Learn the fundamentals of SwiftUI and build beautiful iOS apps.",
                    lessons: 12,
                    duration: "4 hours",
                    imageUrl: nil,
                    categoryId: 1
                )
            )
        }
    }
} 
