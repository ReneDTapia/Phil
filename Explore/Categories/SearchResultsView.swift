//
//  SearchResultsView.swift
//  Phil
//
//  Created on 21/03/24.
//

import SwiftUI

struct SearchResultsView: View {
    var searchText: String
    var results: [Course]
    var isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isLoading {
                ProgressView("Searching...")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else if results.isEmpty {
                Text("No results found for '\(searchText)'")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                Text("Search Results")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                ForEach(results) { course in
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
            }
        }
    }
}

struct SearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultsView(
            searchText: "anxiety",
            results: [
                Course(id: "1", title: "Overcoming Social Anxiety", description: "Learn techniques to manage social anxiety and build confidence in social situations.", lessons: 8, duration: "3 weeks", imageUrl: nil, categoryId: 1)
            ],
            isLoading: false
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
} 
