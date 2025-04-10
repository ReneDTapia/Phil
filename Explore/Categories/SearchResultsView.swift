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
                ProgressView("Buscando...")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else if results.isEmpty {
                Text("No se encontraron resultados para '\(searchText)'")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                Text("Resultados de búsqueda")
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
                                Text("\(course.lessons) \(course.lessons == 1 ? "lección" : "lecciones")")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Spacer()
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
            searchText: "ansiedad",
            results: [
                Course(id: "1", title: "Superar la Ansiedad Social", description: "Aprende técnicas para manejar la ansiedad social y ganar confianza en situaciones sociales.", lessons: 8, imageUrl: nil, categoryId: "anxiety")
            ],
            isLoading: false
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
} 
