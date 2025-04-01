//
//  CategoryDetailView.swift
//  Phil
//
//  Created on 16/03/24.
//

import SwiftUI

struct CategoryDetailView: View {
    // MARK: - Properties
    let categoryId: String
    let categoryTitle: String
    @StateObject private var viewModel = ExploreViewModel()
    @State private var hasAppeared = false
    
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
            if !hasAppeared {
                print("🔍 CategoryDetailView appeared for category: \(categoryId) - \(categoryTitle)")
                viewModel.fetchCoursesByCategory(categoryId: categoryId)
                hasAppeared = true
            }
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
        } else if let errorMessage = viewModel.errorMessage {
            errorView(message: errorMessage)
        } else if viewModel.trendingCourses.isEmpty && viewModel.recommendedCourses.isEmpty {
            emptyStateView
        } else {
            courseListView
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        ProgressView("Cargando cursos...")
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
    }
    
    // MARK: - Error View
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            
            Text("Error al cargar cursos")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.largeTitle)
                .foregroundColor(.gray)
            
            Text("No se encontraron cursos")
                .font(.headline)
            
            Text("No hay cursos disponibles en esta categoría todavía. ¡Vuelve más tarde!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
    }
    
    // MARK: - Course List View
    private var courseListView: some View {
        VStack(alignment: .leading, spacing: 16) {
            let allCourses = viewModel.trendingCourses + viewModel.recommendedCourses
            
            Text("\(allCourses.count) cursos encontrados")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ForEach(allCourses) { course in
                NavigationLink(destination: CourseDetailView(course: course)) {
                    courseCard(for: course)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
            }
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
struct CategoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CategoryDetailView(categoryId: "1", categoryTitle: "Programming")
        }
    }
} 
