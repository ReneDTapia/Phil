//
//  CategoryDetailView.swift
//  Phil
//
//  Created on 16/03/24.
//

import SwiftUI

struct CategoryDetailView: View {
    // MARK: - Properties
    let categoryId: Int
    let categoryTitle: String
    @StateObject private var viewModel = ExploreViewModel()
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                titleView
                contentView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchCoursesByCategory(categoryId: categoryId)
        }
    }
    
    // MARK: - Title View
    private var titleView: some View {
        Text(categoryTitle)
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding()
    }
    
    // MARK: - Content View
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            loadingView
        } else {
            courseListView
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        ProgressView("Loading courses...")
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
    }
    
    // MARK: - Course List View
    private var courseListView: some View {
        ForEach(viewModel.trendingCourses + viewModel.recommendedCourses) { course in
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
            
            Image(systemName: "clock")
                .foregroundColor(.gray)
            Text(course.duration)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Preview
struct CategoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CategoryDetailView(categoryId: 1, categoryTitle: "Programming")
        }
    }
} 
