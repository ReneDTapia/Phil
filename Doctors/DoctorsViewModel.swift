//
//  DoctorsViewModel.swift
//  Phil
//
//  Created by Jesús Daniel Martínez García on 18/03/25.
//

import Foundation
import SwiftUI
import Combine

class DoctorsViewModel: ObservableObject {
    @Published var doctors: [Doctor] = []
    @Published var filteredDoctors: [Doctor] = []
    @Published var searchText: String = ""
    @Published var selectedSpecialties: Set<String> = []
    @Published var selectedModes: Set<ConsultationMode> = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Observar cambios en el texto de búsqueda para filtrar los resultados
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                self?.filterDoctors()
            }
            .store(in: &cancellables)
        
        // Observar cambios en filtros de especialidad
        $selectedSpecialties
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
        
        // Cargar datos de ejemplo inicialmente
        loadSampleData()
    }
    
    // En un entorno real, esto sería reemplazado por una llamada a API
    func loadSampleData() {
        isLoading = true
        
        // Simular carga de red
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            self.doctors = Doctor.sampleDoctors
            self.filteredDoctors = self.doctors
            self.isLoading = false
        }
    }
    
    // En un entorno real, esto sería una llamada API con parámetros de búsqueda
    func fetchDoctors() {
        isLoading = true
        errorMessage = nil
        
        // Simular carga de red
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // En un caso real, esta sería una respuesta de API
            self.doctors = Doctor.sampleDoctors
            self.filterDoctors()
            self.isLoading = false
        }
    }
    
    // Aplicar todos los filtros actuales
    func filterDoctors() {
        var filtered = doctors
        
        // Filtrar por texto de búsqueda
        if !searchText.isEmpty {
            filtered = filtered.filter { doctor in
                doctor.name.lowercased().contains(searchText.lowercased()) ||
                doctor.specialties.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Filtrar por especialidades seleccionadas
        if !selectedSpecialties.isEmpty {
            filtered = filtered.filter { doctor in
                selectedSpecialties.contains { specialty in
                    doctor.specialties.lowercased().contains(specialty.lowercased())
                }
            }
        }
        
        // Filtrar por modos de consulta
        if !selectedModes.isEmpty {
            filtered = filtered.filter { doctor in
                doctor.modes.contains { mode in
                    selectedModes.contains(mode)
                }
            }
        }
        
        filteredDoctors = filtered
    }
    
    // Aplicar o quitar un filtro por especialidad
    func toggleSpecialtyFilter(_ specialty: String) {
        if selectedSpecialties.contains(specialty) {
            selectedSpecialties.remove(specialty)
        } else {
            selectedSpecialties.insert(specialty)
        }
    }
    
    // Aplicar o quitar un filtro por modo de consulta
    func toggleModeFilter(_ mode: ConsultationMode) {
        if selectedModes.contains(mode) {
            selectedModes.remove(mode)
        } else {
            selectedModes.insert(mode)
        }
    }
    
    // Limpiar todos los filtros
    func clearAllFilters() {
        searchText = ""
        selectedSpecialties.removeAll()
        selectedModes.removeAll()
    }
}
