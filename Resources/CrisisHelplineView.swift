//
//  CrisisHelplineView.swift
//  Phil
//
//  Created by Mar Reyes on 10/04/2025.
//


//
//  CrisisHelplineView.swift
//  Phil
//
//  Created by Dario on 24/03/25.
//

import Foundation
import SwiftUI

struct CrisisHelplineView: View {
    @StateObject private var viewModel = CrisisHelplineViewModel()
    @State private var showingFilters = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header section
                VStack(spacing: 16) {
                    // Custom back button and title
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Regresar")
                                    .font(.body)
                            }
                            .foregroundColor(.indigo)
                        }
                        .padding(.leading)
                        
                        Spacer()
                    }
                    .padding(.top, 16)
                    
                    Text("Líneas de Ayuda en México")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    SearchBarView(searchText: $viewModel.searchText, placeholder: "Buscar por tipo de ayuda...")
                    
                    // Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(SupportType.allCases) { supportType in
                                FilterChip(
                                    title: supportType.rawValue,
                                    isSelected: viewModel.selectedSupportTypes.contains(supportType),
                                    action: { viewModel.toggleSupportTypeFilter(supportType) }
                                )
                            }
                            
                            if !viewModel.selectedSupportTypes.isEmpty {
                                Button(action: { viewModel.clearFilters() }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "xmark")
                                            .font(.caption)
                                        Text("Limpiar")
                                            .font(.subheadline)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(16)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 16)
                .background(Color.white)
                
                // Content area
                if viewModel.isLoading {
                    ResourceLoadingView(message: "Cargando líneas de ayuda...")
                } else if let errorMessage = viewModel.errorMessage {
                    ResourceErrorView(message: errorMessage, retryAction: {
                        Task { await viewModel.fetchResources() }
                    })
                } else if viewModel.filteredResources.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("No se encontraron líneas que coincidan con tus criterios")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: { viewModel.clearFilters() }) {
                            Text("Limpiar Filtros")
                                .fontWeight(.semibold)
                                .foregroundColor(.indigo)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            Text("En caso de emergencia, llama al 911")
                                .font(.headline)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                                .padding(.top, 8)
                                
                            ForEach(viewModel.filteredResources) { helpline in
                                CrisisHelplineCard(helpline: helpline)
                            }
                            
                            // Nota informativa
                            Text("Todas estas líneas de ayuda son confidenciales y la mayoría ofrecen asistencia gratuita.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .padding(.top, 16)
                        }
                        .padding()
                    }
                }
            }
            .onAppear {
                Task { await viewModel.fetchResources() }
            }
        }
        .navigationBarHidden(true)
    }
}

struct CrisisHelplineCard: View {
    let helpline: CrisisHelpline
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(helpline.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Disponible \(helpline.availability)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { isExpanded.toggle() }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
            }
            
            // Description and tags
            if isExpanded {
                Text(helpline.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                
                HStack {
                    ForEach(helpline.supportTypes, id: \.self) { type in
                        Text(type.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.indigo.opacity(0.1))
                            .foregroundColor(.indigo)
                            .cornerRadius(12)
                    }
                }
                .padding(.top, 4)
            }
            
            // Call button
            Button(action: {
                let phoneNumber = helpline.phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                guard !phoneNumber.isEmpty else { return }
                let url = URL(string: "tel://\(phoneNumber)")
                if let url = url, UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack {
                    Image(systemName: "phone.fill")
                        .font(.headline)
                    Text("Llamar ahora: \(helpline.phoneNumber)")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.green)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
}