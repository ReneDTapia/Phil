//
//  ExploreView.swift
//  Phil
//
//  Created on 21/03/24.
//

import SwiftUI
import Combine

struct ExploreView: View {
    // MARK: - Properties
    @StateObject private var viewModel = ExploreViewModel()
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var searchTask: Task<Void, Never>?
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Cabecera fija
                VStack(spacing: 16) {
                    headerView
                    searchBar
                }
                .padding(.vertical)
                .background(Color(.systemBackground))
                .zIndex(1) // Aseguramos que permanece encima del contenido
                
                // Contenido scrollable
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if isSearching {
                            searchResultsSection
                        } else {
                            categoriesSection
                            Spacer().frame(height: 10)
                            trendingSection
                        }
                    }
                    .padding(.vertical)
                }
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
            .onAppear {
                print("📱 ExploreView appeared - Fetching data")
                // Fetch courses
                viewModel.fetchCourses()
                
                // Solo obtenemos categorías si no hay ninguna cargada
                if viewModel.categories.isEmpty {
                    print("📱 No hay categorías - obteniendo del API")
                    viewModel.fetchCategories()
                } else {
                    print("📱 Ya hay \(viewModel.categories.count) categorías cargadas, no es necesario obtener de nuevo")
                }
                
                // Update username if needed
                if viewModel.username.isEmpty {
                    if let savedUsername = UserDefaults.standard.string(forKey: "username") {
                        viewModel.username = savedUsername
                    }
                }
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Text("Explorar")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
            NavigationLink(destination: UserView(userId: TokenHelper.getUserID() ?? 0)) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.purple, .indigo]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .shadow(color: .black.opacity(0.2), radius: 2)
                        )
                    
                    Text(viewModel.username.isEmpty ? "U" : getInitials(from: viewModel.username))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Buscar temas...", text: $searchText, onEditingChanged: { _ in
                // Not needed for this functionality
            }, onCommit: {
                if !searchText.isEmpty {
                    isSearching = true
                    performSearch()
                }
            })
            .font(.body)
            .onChange(of: searchText) { newValue in
                handleSearchTextChange(newValue)
            }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    isSearching = false
                    searchTask?.cancel()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(30)
        .padding(.horizontal)
    }
    
    // MARK: - Search Results Section
    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.isLoading {
                loadingView(message: "Buscando...")
            } else if viewModel.searchResults.isEmpty {
                emptyStateView(message: "No se encontraron resultados para '\(searchText)'")
            } else {
                Text("Resultados de búsqueda")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                ForEach(viewModel.searchResults) { course in
                    courseListItem(course: course)
                }
            }
        }
    }
    
    // MARK: - Categories Section
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Categorías")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            if viewModel.isLoading && viewModel.categories.isEmpty {
                ProgressView("Cargando categorías...")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else if viewModel.categories.isEmpty {
                emptyStateView(message: "No hay categorías disponibles")
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(viewModel.categories) { category in
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
    
    // MARK: - Trending Section
    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Tendencias")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink(destination: AllCoursesView(title: "Cursos Populares", courses: viewModel.trendingCourses)) {
                    Image(systemName: "arrow.up.right")
                        .font(.title3)
                        .foregroundColor(.indigo)
                }
            }
            .padding(.horizontal)
            
            // Content
            if viewModel.isLoading {
                loadingView(message: "Cargando cursos...")
            } else if viewModel.trendingCourses.isEmpty {
                emptyStateView(message: "No hay cursos populares disponibles")
            } else {
                // Course List
                VStack(spacing: 16) {
                    ForEach(viewModel.trendingCourses.prefix(2)) { course in
                        NavigationLink(destination: CourseDetailView(course: course)) {
                            CourseCard(
                                title: course.title,
                                lessons: course.lessons,
                                imageUrl: course.imageUrl
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func loadingView(message: String) -> some View {
        ProgressView(message)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
    }
    
    private func emptyStateView(message: String) -> some View {
        Text(message)
            .font(.headline)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
    }
    
    private func courseListItem(course: Course) -> some View {
        NavigationLink(destination: CourseDetailView(course: course)) {
            VStack(alignment: .leading, spacing: 8) {
                Text(course.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(course.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Image(systemName: "book.closed")
                        .foregroundColor(.gray)
                    Text("\(course.lessons) \(course.lessons == 1 ? "lección" : "lecciones")")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                    
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
    
    // MARK: - Helper Methods
    private func handleSearchTextChange(_ newValue: String) {
        if newValue.isEmpty {
            isSearching = false
            searchTask?.cancel()
        } else {
            isSearching = true
            searchTask?.cancel()
            searchTask = Task {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 segundos de debounce
                if !Task.isCancelled {
                    performSearch()
                }
            }
        }
    }
    
    private func performSearch() {
        Task {
            await viewModel.searchCourses(query: searchText)
        }
    }
    
    // Helper function to get initials
    private func getInitials(from name: String) -> String {
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1))
        } else if !components.isEmpty {
            return String(components[0].prefix(1))
        }
        return ""
    }
}

// MARK: - Preview
struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
