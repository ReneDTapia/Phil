//
//  ResourceViewModels.swift
//  Phil
//
//  Created by Dario on 24/03/25.
//

import Foundation
import Combine
import SwiftUI

/// Base protocol for all resource view models to ensure consistency
protocol ResourceViewModel: ObservableObject {
    associatedtype ResourceType
    
    var isLoading: Bool { get set }
    var errorMessage: String? { get set }
    var resources: [ResourceType] { get set }
    
    func fetchResources() async
    func search(query: String)
}

// MARK: - Crisis Helpline ViewModel

class CrisisHelplineViewModel: ObservableObject, ResourceViewModel {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var resources: [CrisisHelpline] = []
    @Published var filteredResources: [CrisisHelpline] = []
    @Published var searchText: String = ""
    @Published var selectedSupportTypes: Set<SupportType> = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Combine text search with selected filters
        Publishers.CombineLatest($searchText, $selectedSupportTypes)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] (searchText, supportTypes) in
                self?.applyFilters(searchText: searchText, supportTypes: supportTypes)
            }
            .store(in: &cancellables)
    }
    
    func fetchResources() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        do {
            // This would be an API call in a real app
            let fetchedResources = CrisisHelpline.sampleHelplines
            
            await MainActor.run {
                self.resources = fetchedResources
                self.filteredResources = fetchedResources
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load helplines: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func search(query: String) {
        searchText = query
    }
    
    func toggleSupportTypeFilter(_ supportType: SupportType) {
        if selectedSupportTypes.contains(supportType) {
            selectedSupportTypes.remove(supportType)
        } else {
            selectedSupportTypes.insert(supportType)
        }
    }
    
    private func applyFilters(searchText: String, supportTypes: Set<SupportType>) {
        var filtered = resources
        
        // Apply text search
        if !searchText.isEmpty {
            filtered = filtered.filter { helpline in
                helpline.name.localizedCaseInsensitiveContains(searchText) ||
                helpline.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply support type filters
        if !supportTypes.isEmpty {
            filtered = filtered.filter { helpline in
                !Set(helpline.supportTypes).isDisjoint(with: supportTypes)
            }
        }
        
        filteredResources = filtered
    }
    
    func clearFilters() {
        searchText = ""
        selectedSupportTypes.removeAll()
    }
}

// MARK: - Support Group ViewModel

class SupportGroupViewModel: ObservableObject, ResourceViewModel {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var resources: [SupportGroup] = []
    @Published var filteredResources: [SupportGroup] = []
    @Published var searchText: String = ""
    @Published var selectedFormats: Set<MeetingFormat> = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Combine text search with selected filters
        Publishers.CombineLatest($searchText, $selectedFormats)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] (searchText, formats) in
                self?.applyFilters(searchText: searchText, formats: formats)
            }
            .store(in: &cancellables)
    }
    
    func fetchResources() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        do {
            // This would be an API call in a real app
            let fetchedResources = SupportGroup.sampleGroups
            
            await MainActor.run {
                self.resources = fetchedResources
                self.filteredResources = fetchedResources
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load support groups: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func search(query: String) {
        searchText = query
    }
    
    func toggleFormatFilter(_ format: MeetingFormat) {
        if selectedFormats.contains(format) {
            selectedFormats.remove(format)
        } else {
            selectedFormats.insert(format)
        }
    }
    
    private func applyFilters(searchText: String, formats: Set<MeetingFormat>) {
        var filtered = resources
        
        // Apply text search
        if !searchText.isEmpty {
            filtered = filtered.filter { group in
                group.name.localizedCaseInsensitiveContains(searchText) ||
                group.description.localizedCaseInsensitiveContains(searchText) ||
                group.focusArea.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply format filters
        if !formats.isEmpty {
            filtered = filtered.filter { group in
                formats.contains(group.meetingFormat)
            }
        }
        
        filteredResources = filtered
    }
    
    func clearFilters() {
        searchText = ""
        selectedFormats.removeAll()
    }
}

// MARK: - Self-Help Tools ViewModel

class SelfHelpToolsViewModel: ObservableObject, ResourceViewModel {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var resources: [SelfHelpTool] = []
    @Published var filteredResources: [SelfHelpTool] = []
    @Published var searchText: String = ""
    @Published var selectedCategories: Set<ToolCategory> = []
    @Published var selectedFormats: Set<ToolFormat> = []
    @Published var selectedDifficulty: ToolDifficulty? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Combine all filter publishers
        Publishers.CombineLatest4(
            $searchText,
            $selectedCategories,
            $selectedFormats,
            $selectedDifficulty
        )
        .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
        .sink { [weak self] (searchText, categories, formats, difficulty) in
            self?.applyFilters(
                searchText: searchText,
                categories: categories,
                formats: formats,
                difficulty: difficulty
            )
        }
        .store(in: &cancellables)
    }
    
    func fetchResources() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        do {
            // This would be an API call in a real app
            let fetchedResources = SelfHelpTool.sampleTools
            
            await MainActor.run {
                self.resources = fetchedResources
                self.filteredResources = fetchedResources
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load self-help tools: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func search(query: String) {
        searchText = query
    }
    
    func toggleCategoryFilter(_ category: ToolCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
    
    func toggleFormatFilter(_ format: ToolFormat) {
        if selectedFormats.contains(format) {
            selectedFormats.remove(format)
        } else {
            selectedFormats.insert(format)
        }
    }
    
    func setDifficultyFilter(_ difficulty: ToolDifficulty?) {
        selectedDifficulty = difficulty
    }
    
    private func applyFilters(
        searchText: String,
        categories: Set<ToolCategory>,
        formats: Set<ToolFormat>,
        difficulty: ToolDifficulty?
    ) {
        var filtered = resources
        
        // Apply text search
        if !searchText.isEmpty {
            filtered = filtered.filter { tool in
                tool.name.localizedCaseInsensitiveContains(searchText) ||
                tool.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply category filters
        if !categories.isEmpty {
            filtered = filtered.filter { tool in
                categories.contains(tool.category)
            }
        }
        
        // Apply format filters
        if !formats.isEmpty {
            filtered = filtered.filter { tool in
                formats.contains(tool.format)
            }
        }
        
        // Apply difficulty filter
        if let selectedDifficulty = difficulty {
            filtered = filtered.filter { tool in
                tool.difficulty == selectedDifficulty
            }
        }
        
        filteredResources = filtered
    }
    
    func clearFilters() {
        searchText = ""
        selectedCategories.removeAll()
        selectedFormats.removeAll()
        selectedDifficulty = nil
    }
}
