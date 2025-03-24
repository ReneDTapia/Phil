//
//  SupportGroupsView.swift
//  Phil
//
//  Created by Dario on 24/03/25.
//

import SwiftUI

struct SupportGroupsView: View {
    // Use the view model from ResourceViewModels.swift
    @StateObject private var viewModel = SupportGroupViewModel()
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemGray6)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Content
                if viewModel.isLoading {
                    loadingView
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(message: errorMessage)
                } else if viewModel.filteredResources.isEmpty {
                    emptyResultsView
                } else {
                    supportGroupsList
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .onAppear {
                Task {
                    await viewModel.fetchResources()
                }
            }
        }
    }
    
    // MARK: - UI Components
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Title and back button
            ResourceHeaderView(title: "Support Groups", showBackButton: true)
            
            // Search bar
            SearchBarView(searchText: $viewModel.searchText, placeholder: "Search support groups...")
            
            // Filter chips for meeting formats
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MeetingFormat.allCases) { format in
                        FilterChip(
                            title: format.rawValue,
                            isSelected: viewModel.selectedFormats.contains(format),
                            action: { viewModel.toggleFormatFilter(format) }
                        )
                    }
                    
                    if !viewModel.selectedFormats.isEmpty {
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
                Text("Clear")
                    .font(.subheadline)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemGray5))
            .cornerRadius(16)
        }
    }
    
    private var loadingView: some View {
        ResourceLoadingView(message: "Loading support groups...")
    }
    
    private func errorView(message: String) -> some View {
        ResourceErrorView(message: message) {
            Task { await viewModel.fetchResources() }
        }
    }
    
    private var emptyResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("No support groups found matching your criteria")
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
    
    private var supportGroupsList: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.filteredResources) { group in
                    SupportGroupCard(group: group)
                }
            }
            .padding()
        }
    }
}

// MARK: - Support Group Card

struct SupportGroupCard: View {
    let group: SupportGroup
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            cardHeader
            
            // Format and schedule badge
            formatBadge
            
            // Expanded content (description and more details)
            if isExpanded {
                expandedContent
            }
            
            // Join button
            joinButton
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
    
    // MARK: - Card Components
    
    private var cardHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(group.focusArea)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: { isExpanded.toggle() }) {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var formatBadge: some View {
        HStack(spacing: 8) {
            formatIcon
            
            Text(group.schedule)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var formatIcon: some View {
        Group {
            switch group.meetingFormat {
            case .inPerson:
                Label("In-Person", systemImage: "person.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
            case .online:
                Label("Online", systemImage: "video.fill")
                    .font(.caption)
                    .foregroundColor(.green)
            case .hybrid:
                Label("Hybrid", systemImage: "person.2.fill")
                    .font(.caption)
                    .foregroundColor(.purple)
            }
        }
    }
    
    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(group.description)
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.vertical, 8)
            
            // Location (if applicable)
            locationDetails
            
            // Facilitator info (if available)
            facilitatorInfo
        }
    }
    
    private var locationDetails: some View {
        Group {
            if group.meetingFormat != .online, let location = group.location {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if group.meetingFormat != .inPerson, let onlineLink = group.onlineLink {
                HStack(spacing: 4) {
                    Image(systemName: "link.circle.fill")
                        .foregroundColor(.blue)
                    Text(onlineLink)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .underline()
                        .onTapGesture {
                            if let url = URL(string: onlineLink) {
                                UIApplication.shared.open(url)
                            }
                        }
                }
            }
        }
    }
    
    private var facilitatorInfo: some View {
        Group {
            if let facilitator = group.facilitator {
                HStack(spacing: 4) {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.indigo)
                    Text("Facilitated by: \(facilitator)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
        }
    }
    
    private var joinButton: some View {
        Button(action: {
            // Action to join group would go here
        }) {
            HStack {
                Image(systemName: "person.badge.plus")
                    .font(.headline)
                Text("Learn More & Join")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.indigo)
            .cornerRadius(12)
        }
    }
}

