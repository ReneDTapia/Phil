//
//  SelfHelpToolsView.swift
//  Phil
//
//  Created by Mar Reyes on 10/04/2025.
//


//
//  SelfHelpToolsView.swift
//  Phil
//
//  Created by Dario on 3/22/25.
//

import SwiftUI

struct SelfHelpToolsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.primary)
                                .padding(10)
                                .background(Circle().fill(Color.white))
                                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                        }
                        
                        Text("Self-Help Tools")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Search bar and filter button
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            Text("Search tools...")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(25)
                        
                        Button(action: {}) {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.primary)
                                .padding(10)
                                .background(Circle().fill(Color.white))
                                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 16)
                .background(Color.white)
                
                // Tools grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        sampleTool(
                            name: "5-Minute Calming Breath",
                            category: "Breathing",
                            format: "Audio",
                            difficulty: "Beginner"
                        )
                        
                        sampleTool(
                            name: "Mindful Body Scan",
                            category: "Meditation",
                            format: "Audio",
                            difficulty: "Beginner"
                        )
                        
                        sampleTool(
                            name: "Cognitive Distortions",
                            category: "Cognitive",
                            format: "Interactive",
                            difficulty: "Intermediate"
                        )
                        
                        sampleTool(
                            name: "Gratitude Journaling",
                            category: "Journaling",
                            format: "Article",
                            difficulty: "Beginner"
                        )
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // Sample tool card
    private func sampleTool(name: String, category: String, format: String, difficulty: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Tool thumbnail
            ZStack {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .aspectRatio(16/9, contentMode: .fill)
                    .cornerRadius(12)
                
                Image(systemName: "book.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.gray)
                
                // Difficulty badge
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(difficulty)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(8)
                            .padding(8)
                    }
                }
            }
            .frame(height: 120)
            
            // Tool details
            VStack(alignment: .leading, spacing: 6) {
                // Category & Format
                HStack {
                    Text(category)
                        .font(.caption)
                        .foregroundColor(.indigo)
                    
                    Spacer()
                    
                    Text(format)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Title
                Text(name)
                    .font(.headline)
                    .lineLimit(2)
                
                // Duration
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("5-15 minutes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
}

struct SelfHelpToolsView_Previews: PreviewProvider {
    static var previews: some View {
        SelfHelpToolsView()
    }
}