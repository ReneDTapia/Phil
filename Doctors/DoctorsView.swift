//
//  DoctorsView.swift
//  Phil
//
//  Created by Jesús Daniel Martínez García on 18/03/25.
//

import SwiftUI

struct DoctorsView: View {
    @StateObject private var viewModel = DoctorsViewModel()
    @State private var showFilters = false
    
    var body: some View {
        // Utilizamos un NavigationView solo cuando se muestra independientemente
        // esto sería reemplazado por NavigationStack en iOS 16+
        NavigationView {
            ZStack {
                // Fondo general
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Encabezado con título y buscador
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Find Help")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top, 16)
                        
                        // Barra de búsqueda
                        HStack {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                TextField("Search specialists...", text: $viewModel.searchText)
                                    .font(.body)
                                
                                if !viewModel.searchText.isEmpty {
                                    Button(action: {
                                        viewModel.searchText = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(25)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            
                            // Botón de filtros
                            Button(action: {
                                showFilters.toggle()
                            }) {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(12)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    .background(Color.white)
                    
                    // Contenido principal
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView("Loading specialists...")
                            .progressViewStyle(CircularProgressViewStyle())
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 24) {
                                // Lista de doctores
                                VStack(spacing: 16) {
                                    let doctorsToShow = viewModel.filteredDoctors.isEmpty && viewModel.selectedModes.isEmpty && viewModel.selectedCategories.isEmpty ? viewModel.doctors : viewModel.filteredDoctors
                                    
                                    if doctorsToShow.isEmpty {
                                        Text("No doctors match your filters")
                                            .font(.headline)
                                            .foregroundColor(.gray)
                                            .padding(.top, 40)
                                    } else {
                                        ForEach(doctorsToShow) { doctor in
                                            NavigationLink {
                                                DoctorsDetailView(doctor: doctor)
                                            } label: {
                                                DoctorCardView(doctor: doctor)
                                                    .contentShape(Rectangle()) // Asegurar que toda el área sea tocable
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 8)
                                
                                // Sección de recursos adicionales
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("Additional Resources")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    // Lista de recursos
                                    ResourceCardView(
                                        title: "Crisis Helpline",
                                        description: "Immediate support during emotional crisis",
                                        iconName: "phone.fill"
                                    )
                                    
                                    ResourceCardView(
                                        title: "Support Groups",
                                        description: "Connect with others facing similar challenges",
                                        iconName: "person.3.fill"
                                    )
                                    
                                    ResourceCardView(
                                        title: "Self-Help Tools",
                                        description: "Practices and exercises for daily mental health",
                                        iconName: "book.fill"
                                    )
                                }
                                .padding(20)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 16)
                            }
                        }
                    }
                }
                .sheet(isPresented: $showFilters) {
                    FiltersView(viewModel: viewModel)
                }
                .onAppear {
                    if viewModel.doctors.isEmpty {
                        viewModel.fetchDoctors()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// Componente de tarjeta de doctor
struct DoctorCardView: View {
    let doctor: Doctor
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 15) {
                // Foto del doctor
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    if let imageURL = doctor.imageURL, let url = URL(string: imageURL) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.gray)
                            }
                        }
                    } else {
                        Image(systemName: "person.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gray)
                    }
                }
                
                // Información del doctor
                VStack(alignment: .leading, spacing: 4) {
                    // Nombre
                    Text(doctor.name)
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    // Especialidad
                    Text(doctor.specialties)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Calificación
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.subheadline)
                        
                        Text(String(format: "%.1f", doctor.rating))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        Text("(\(doctor.reviewCount))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // Disponibilidad
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text(doctor.availability.displayText)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 2)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            
            // Barra inferior con modos de consulta y precio
            HStack {
                // Modos de consulta
                HStack(spacing: 8) {
                    ForEach(doctor.modes) { mode in
                        Text(mode.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.indigo.opacity(0.1))
                            .foregroundColor(.indigo)
                            .cornerRadius(16)
                    }
                }
                
                Spacer()
                
                // Precio
                Text("$\(doctor.price)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.indigo)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

// Componente para recursos
struct ResourceCardView: View {
    let title: String
    let description: String
    let iconName: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Ícono
            ZStack {
                Circle()
                    .fill(Color.indigo.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: iconName)
                    .font(.title3)
                    .foregroundColor(.indigo)
            }
            
            // Texto
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Flecha
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.subheadline)
        }
        .padding(.vertical, 10)
    }
}

// Vista de filtros
struct FiltersView: View {
    @ObservedObject var viewModel: DoctorsViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // Opciones de categorías disponibles
    let categories = ["Ansiedad", "Autoestima", "Depresión", "Estrés", "Relaciones", "Sueño"]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                List {
                    // Sección de modos de consulta
                    Section(header: Text("Consultation type").font(.headline)) {
                        ForEach(ConsultationMode.allCases) { mode in
                            Button(action: {
                                viewModel.toggleModeFilter(mode)
                            }) {
                                HStack {
                                    Text(mode.rawValue)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    if viewModel.selectedModes.contains(mode) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Sección de categorías
                    Section(header: Text("Categories").font(.headline)) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                viewModel.toggleCategoryFilter(category)
                            }) {
                                HStack {
                                    Text(category)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    if viewModel.selectedCategories.contains(category) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Botones de acción en la parte inferior
                HStack {
                    Button(action: {
                        viewModel.clearAllFilters()
                    }) {
                        Text("Reset All")
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                    }
                    
                    Button(action: {
                        viewModel.filterDoctors() // Asegurarse de que se apliquen los filtros
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Apply")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding(16)
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

struct DoctorsView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorsView()
    }
}
