//
//  SelfHelpToolsView.swift
//  Phil
//
//  Created by Dario on 24/03/25.
//

import SwiftUI

struct SelfHelpToolsView: View {
    @StateObject private var viewModel = SelfHelpToolsViewModel()
    @State private var showingFilterSheet = false
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemGray6)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Content
                contentSection
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .onAppear {
                Task {
                    await viewModel.fetchResources()
                }
            }
            .sheet(isPresented: $showingFilterSheet) {
                ToolFilterSheet(viewModel: viewModel)
            }
        }
    }
    
    // MARK: - UI Components
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Title and back button
            ResourceHeaderView(title: "Self-Help Tools", showBackButton: true)
            
            // Search bar and filter button
            HStack {
                SearchBarView(searchText: $viewModel.searchText, placeholder: "Search tools...")
                
                Button(action: { showingFilterSheet = true }) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.primary)
                        .padding(10)
                        .background(Circle().fill(Color.white))
                        .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                }
                .padding(.trailing, 16)
            }
            
            // Category filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ToolCategory.allCases) { category in
                        FilterChip(
                            title: category.rawValue,
                            isSelected: viewModel.selectedCategories.contains(category),
                            action: { viewModel.toggleCategoryFilter(category) }
                        )
                    }
                    
                    if !viewModel.selectedCategories.isEmpty || 
                       !viewModel.selectedFormats.isEmpty || 
                       viewModel.selectedDifficulty != nil {
                        clearFiltersButton
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 16)
        .background(Color.white)
    }
    
    private var clearFiltersButton: some View {
        Button(action: { viewModel.clearFilters() }) {
            HStack(spacing: 4) {
                Image(systemName: "xmark")
                    .font(.caption)
                Text("Clear All")
                    .font(.subheadline)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemGray5))
            .cornerRadius(16)
        }
    }
    
    private var contentSection: some View {
        Group {
            if viewModel.isLoading {
                ResourceLoadingView(message: "Loading self-help tools...")
            } else if let errorMessage = viewModel.errorMessage {
                ResourceErrorView(message: errorMessage) {
                    Task { await viewModel.fetchResources() }
                }
            } else if viewModel.filteredResources.isEmpty {
                emptyResultsView
            } else {
                toolsGridView
            }
        }
    }
    
    private var emptyResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("No tools found matching your criteria")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: { viewModel.clearFilters() }) {
                Text("Clear Filters")
                    .fontWeight(.semibold)
                    .foregroundColor(.indigo)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var toolsGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(viewModel.filteredResources) { tool in
                    SelfHelpToolCard(tool: tool)
                }
            }
            .padding()
        }
    }
}

// MARK: - Self-Help Tool Card

struct SelfHelpToolCard: View {
    let tool: SelfHelpTool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Tool thumbnail
            ZStack {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .aspectRatio(16/9, contentMode: .fill)
                    .cornerRadius(12)
                
                thumbnailImage
                
                // Difficulty badge
                difficultyBadge
            }
            .frame(height: 120)
            
            // Tool details
            toolDetails
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
    
    // MARK: - Card Components
    
    private var thumbnailImage: some View {
        Group {
            if let imageURL = tool.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .cornerRadius(12)
                            .clipped()
                    } else {
                        formatIcon
                    }
                }
            } else {
                formatIcon
            }
        }
    }
    
    private var formatIcon: some View {
        Image(systemName: toolFormatIcon(tool.format))
            .font(.system(size: 30))
            .foregroundColor(.gray)
    }
    
    private var difficultyBadge: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text(tool.difficulty.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(difficultyColor(tool.difficulty).opacity(0.2))
                    .foregroundColor(difficultyColor(tool.difficulty))
                    .cornerRadius(8)
                    .padding(8)
            }
        }
    }
    
    private var toolDetails: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Category & Format
            HStack {
                Text(tool.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.indigo)
                
                Spacer()
                
                Text(tool.format.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Title
            Text(tool.name)
                .font(.headline)
                .lineLimit(2)
            
            // Duration if available
            if let duration = tool.duration {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(duration)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }
    
    // MARK: - Helper Methods
    
    private func toolFormatIcon(_ format: ToolFormat) -> String {
        switch format {
        case .exercise: return "figure.walk"
        case .article: return "doc.text"
        case .audio: return "headphones"
        case .video: return "play.rectangle"
        case .interactive: return "hand.tap"
        }
    }
    
    private func difficultyColor(_ difficulty: ToolDifficulty) -> Color {
        switch difficulty {
        case .beginner: return .green
        case .intermediate: return .blue
        case .advanced: return .purple
        }
    }
}

// MARK: - Filter Sheet

struct ToolFilterSheet: View {
    @ObservedObject var viewModel: SelfHelpToolsViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                // Format section
                Section(header: Text("Format").font(.headline)) {
                    ForEach(ToolFormat.allCases) { format in
                        formatToggleRow(format)
                    }
                }
                
                // Difficulty section
                Section(header: Text("Difficulty").font(.headline)) {
                    ForEach(ToolDifficulty.allCases) { difficulty in
                        difficultySelectRow(difficulty)
                    }
                }
                
                // Action buttons
                Section {
                    Button(action: { 
                        viewModel.clearFilters()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Clear All Filters")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Filter Tools")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func formatToggleRow(_ format: ToolFormat) -> some View {
        Button(action: { viewModel.toggleFormatFilter(format) }) {
            HStack {
                Image(systemName: viewModel.selectedFormats.contains(format) ? "checkmark.square.fill" : "square")
                    .foregroundColor(viewModel.selectedFormats.contains(format) ? .blue : .gray)
                
                Text(format.rawValue)
                    .foregroundColor(.primary)
                
                Spacer()
            }
        }
    }
    
    private func difficultySelectRow(_ difficulty: ToolDifficulty) -> some View {
        Button(action: {
            if viewModel.selectedDifficulty == difficulty {
                viewModel.setDifficultyFilter(nil)
            } else {
                viewModel.setDifficultyFilter(difficulty)
            }
        }) {
            HStack {
                Image(systemName: viewModel.selectedDifficulty == difficulty ? "circle.fill" : "circle")
                    .foregroundColor(viewModel.selectedDifficulty == difficulty ? .blue : .gray)
                
                Text(difficulty.rawValue)
                    .foregroundColor(.primary)
                
                Spacer()
            }
        }
    }
}
