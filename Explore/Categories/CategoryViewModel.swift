//
//  CategoryViewModel.swift
//  Phil
//
//  Created by Dario on 22/03/25.
//

import SwiftUI
import Foundation

class CategoryViewModel: ObservableObject {
    @Published var resultCategories: [CategoryModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    func getCategories() async {
        isLoading = true
        
        do {
            let categories: [CategoryModel] = try await APIClient.get(path: "getCategories")
            DispatchQueue.main.async {
                self.resultCategories = categories
                self.isLoading = false
                
                // Debug information
                print("Number of categories fetched: \(categories.count)")
                for category in categories {
                    print("Category ID: \(category.id), Name: \(category.name)")
                    print("Emoji: \(category.emoji ?? "No emoji"), Color: \(category.color ?? "No color")")
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                print("Error fetching categories: \(error)")
            }
        }
    }
}
