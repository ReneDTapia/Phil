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
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerView
                    searchBar
                    
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
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
            .onAppear {
                viewModel.fetchCourses()
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Text("Explore")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: {
                // Profile action
            }) {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search for topics...", text: $searchText, onEditingChanged: { _ in
                // Not needed for this functionality
            }, onCommit: {
                if !searchText.isEmpty {
                    isSearching = true
                    viewModel.searchCourses(query: searchText)
                }
            })
            .font(.body)
            .onReceive(Just(searchText)) { newValue in
                handleSearchTextChange(newValue)
            }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    isSearching = false
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
                loadingView(message: "Searching...")
            } else if viewModel.searchResults.isEmpty {
                emptyStateView(message: "No results found for '\(searchText)'")
            } else {
                Text("Search Results")
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
            Text("Categories")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
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
    
    // MARK: - Trending Section
    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Trending Now")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink(destination: AllCoursesView(title: "Trending Courses", courses: viewModel.trendingCourses)) {
                    Image(systemName: "arrow.up.right")
                        .font(.title3)
                        .foregroundColor(.indigo)
                }
            }
            .padding(.horizontal)
            
            // Content
            if viewModel.isLoading {
                loadingView(message: "Loading courses...")
            } else if viewModel.trendingCourses.isEmpty {
                emptyStateView(message: "No trending courses available")
            } else {
                // Course List
                VStack(spacing: 16) {
                    ForEach(viewModel.trendingCourses.prefix(2)) { course in
                        NavigationLink(destination: CourseDetailView(course: course)) {
                            CourseCard(
                                title: course.title,
                                lessons: course.lessons,
                                duration: course.duration,
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
        } else {
            isSearching = true
            viewModel.searchCourses(query: newValue)
        }
    }
}

// MARK: - Preview
struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
