//
//  AllCoursesView.swift
//  Phil
//
//  Created on 16/03/24.
//

import SwiftUI

struct AllCoursesView: View {
    // MARK: - Properties
    let title: String
    let courses: [Course]
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                titleView
                courseListView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Title View
    private var titleView: some View {
        Text(title)
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding()
    }
    
    // MARK: - Course List View
    private var courseListView: some View {
        ForEach(courses) { course in
            NavigationLink(destination: CourseDetailView(course: course)) {
                courseCard(for: course)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal)
        }
    }
    
    // MARK: - Course Card
    private func courseCard(for course: Course) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(course.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(course.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            courseMetadata(for: course)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Course Metadata
    private func courseMetadata(for course: Course) -> some View {
        HStack {
            Image(systemName: "book.closed")
                .foregroundColor(.gray)
            Text("\(course.lessons) lessons")
                .font(.caption)
                .foregroundColor(.gray)
            
            Spacer()
        }
    }
}

// MARK: - Preview
struct AllCoursesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AllCoursesView(
                title: "All Courses",
                courses: [
                    Course(
                        id: "1",
                        title: "SwiftUI Essentials",
                        description: "Learn the fundamentals of SwiftUI and build beautiful iOS apps.",
                        lessons: 12,
                        imageUrl: nil,
                        categoryId: "1"
                    ),
                    Course(
                        id: "2",
                        title: "Advanced Swift",
                        description: "Take your Swift skills to the next level with advanced techniques.",
                        lessons: 15,
                        imageUrl: nil,
                        categoryId: "1"
                    )
                ]
            )
        }
    }
} 
