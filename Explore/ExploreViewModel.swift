//
//  ExploreViewModel.swift
//  Phil
//
//  Created on 21/03/24.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Models

struct Course: Identifiable {
    let id: String
    let title: String
    let description: String
    let lessons: Int
    let duration: String
    let imageUrl: String?
    let categoryId: Int
}

struct Category: Identifiable {
    let id: Int
    let title: String
    let emoji: String
    let color: Color
}

// MARK: - ViewModel

class ExploreViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var trendingCourses: [Course] = []
    @Published var recommendedCourses: [Course] = []
    @Published var categories: [Category] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchResults: [Course] = []
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        loadMockData()
    }
    
    // MARK: - Public Methods
    
    /// Fetches all courses and categories
    func fetchCourses() {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            self.loadMockData()
            self.isLoading = false
        }
    }
    
    /// Fetches courses filtered by category
    /// - Parameter categoryId: The ID of the category to filter by
    func fetchCoursesByCategory(categoryId: Int) {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            // Load all mock data first
            self.loadMockData()
            
            // Filter courses by category
            self.trendingCourses = self.trendingCourses.filter { $0.categoryId == categoryId }
            self.recommendedCourses = self.recommendedCourses.filter { $0.categoryId == categoryId }
            
            self.isLoading = false
        }
    }
    
    /// Searches for courses matching the query
    /// - Parameter query: The search query
    func searchCourses(query: String) {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }
            
            // Filter courses by search query
            let lowercasedQuery = query.lowercased()
            self.searchResults = self.trendingCourses.filter { course in
                course.title.lowercased().contains(lowercasedQuery) ||
                course.description.lowercased().contains(lowercasedQuery)
            }
            self.isLoading = false
        }
    }
    
    // MARK: - Private Methods
    
    /// Loads mock data for testing
    private func loadMockData() {
        // Mock categories with numeric IDs
        categories = [
            Category(id: 1, title: "Anxiety", emoji: "🧠", color: Color.pink.opacity(0.3)),
            Category(id: 2, title: "Depression", emoji: "💙", color: Color.blue.opacity(0.3)),
            Category(id: 3, title: "Stress", emoji: "😓", color: Color.orange.opacity(0.3)),
            Category(id: 4, title: "Sleep", emoji: "😴", color: Color.cyan.opacity(0.3)),
            Category(id: 5, title: "Relationships", emoji: "❤️", color: Color.red.opacity(0.3)),
            Category(id: 6, title: "Self-Esteem", emoji: "🌟", color: Color.purple.opacity(0.3))
        ]
        
        // Mock trending courses with numeric category IDs
        trendingCourses = [
            Course(id: "1", title: "Overcoming Social Anxiety", description: "Learn techniques to manage social anxiety and build confidence in social situations.", lessons: 8, duration: "3 weeks", imageUrl: nil, categoryId: 1),
            Course(id: "2", title: "Mindfulness for Beginners", description: "Start your mindfulness journey with simple daily practices for stress reduction.", lessons: 12, duration: "4 weeks", imageUrl: nil, categoryId: 3),
            Course(id: "3", title: "Building Healthy Habits", description: "Develop sustainable habits that improve your mental and physical wellbeing.", lessons: 10, duration: "6 weeks", imageUrl: nil, categoryId: 6),
            Course(id: "4", title: "Effective Communication", description: "Enhance your communication skills to build better relationships.", lessons: 6, duration: "2 weeks", imageUrl: nil, categoryId: 5)
        ]
        
        // Mock recommended courses with numeric category IDs
        recommendedCourses = [
            Course(id: "5", title: "Stress Management", description: "Practical techniques to manage stress in your daily life.", lessons: 9, duration: "3 weeks", imageUrl: nil, categoryId: 3),
            Course(id: "6", title: "Emotional Intelligence", description: "Develop your emotional awareness and regulation skills.", lessons: 7, duration: "2 weeks", imageUrl: nil, categoryId: 6),
            Course(id: "7", title: "Sleep Improvement", description: "Strategies to improve your sleep quality and duration.", lessons: 5, duration: "2 weeks", imageUrl: nil, categoryId: 4),
            Course(id: "8", title: "Managing Depression", description: "Evidence-based approaches to cope with depression symptoms.", lessons: 10, duration: "4 weeks", imageUrl: nil, categoryId: 2)
        ]
    }
}
