//  DoctorsViewModel.swift
//  Phil
//
//  Created by Jesús Daniel Martínez García on 18/03/25.

import Foundation
import SwiftUI
import Combine

class DoctorsViewModel: ObservableObject {
    @Published var doctors: [Doctor] = []
    @Published var filteredDoctors: [Doctor] = []
    @Published var searchText: String = ""
    @Published var selectedModes: Set<ConsultationMode> = []
    @Published var selectedCategories: Set<String> = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Observar cambios en el texto de búsqueda
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.filterDoctors()
            }
            .store(in: &cancellables)

        // Observar cambios en filtros de modo de consulta
        $selectedModes
            .sink { [weak self] _ in
                self?.filterDoctors()
            }
            .store(in: &cancellables)

        // Observar cambios en filtros de categorías
        $selectedCategories
            .sink { [weak self] _ in
                self?.filterDoctors()
            }
            .store(in: &cancellables)

        // Cargar doctores desde la API al iniciar
        fetchDoctors()
    }

    func fetchDoctors() {
        print("Calling fetchDoctors...")
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let apiDoctors: [Doctor] = try await APIClient.get(path: "getAllDoctors")
                DispatchQueue.main.async {
                    print("Doctors received: \(apiDoctors.count)")
                    self.doctors = apiDoctors
                    self.filterDoctors()
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Error loading doctors: \(error.localizedDescription)"
                    self.isLoading = false
                    print("Fetch error: \(error)")
                }
            }
        }
    }

    // Aplicar todos los filtros actuales
    func filterDoctors() {
        print("Filtering doctors with: \(selectedModes.count) modes, \(selectedCategories.count) categories")
        
        var filtered = doctors

        // Filtrar por texto de búsqueda
        if !searchText.isEmpty {
            filtered = filtered.filter { doctor in
                doctor.name.lowercased().contains(searchText.lowercased()) ||
                doctor.specialties.lowercased().contains(searchText.lowercased())
            }
        }

        // Filtrar por modos de consulta
        if !selectedModes.isEmpty {
            print("Filtering by modes: \(selectedModes.map { $0.rawValue }.joined(separator: ", "))")
            filtered = filtered.filter { doctor in
                for selectedMode in selectedModes {
                    if !doctor.modes.contains(selectedMode) {
                        // Si el doctor no tiene alguno de los modos seleccionados, no lo incluimos
                        return false
                    }
                }
                return true
            }
            print("After mode filtering: \(filtered.count) doctors")
        }

        // Filtrar por categorías
        if !selectedCategories.isEmpty {
            print("Filtering by categories: \(selectedCategories.joined(separator: ", "))")
            filtered = filtered.filter { doctor in
                for selectedCategory in selectedCategories {
                    let hasCategory = doctor.categories.contains { category in
                        category.lowercased() == selectedCategory.lowercased()
                    }
                    
                    if !hasCategory {
                        // Si el doctor no tiene alguna de las categorías seleccionadas, no lo incluimos
                        return false
                    }
                }
                return true
            }
            print("After category filtering: \(filtered.count) doctors")
        }

        // Actualizar la lista filtrada
        filteredDoctors = filtered
        print("Final filtered doctors count: \(filteredDoctors.count)")
    }

    // Aplicar o quitar un filtro por modo de consulta
    func toggleModeFilter(_ mode: ConsultationMode) {
        if selectedModes.contains(mode) {
            selectedModes.remove(mode)
        } else {
            selectedModes.insert(mode)
        }
    }

    // Aplicar o quitar un filtro por categoría
    func toggleCategoryFilter(_ category: String) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }

    // Limpiar todos los filtros
    func clearAllFilters() {
        searchText = ""
        selectedModes.removeAll()
        selectedCategories.removeAll()
    }
}
