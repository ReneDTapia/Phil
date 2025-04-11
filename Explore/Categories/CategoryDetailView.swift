//
//  CategoryDetailView.swift
//  Phil
//
//  Created on 16/03/24.
//

import SwiftUI
import KeychainSwift

struct CategoryDetailView: View {
    // MARK: - Properties
    let categoryId: String
    let categoryTitle: String
    @StateObject private var viewModel = ExploreViewModel()
    @State private var hasAppeared = false
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                titleView
                contentView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
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
            }
        }
        .onAppear {
            if !hasAppeared {
                print("🔍 CategoryDetailView appeared for category: \(categoryId) - \(categoryTitle)")
                viewModel.fetchContentsByCategory(categoryId: categoryId)
                hasAppeared = true
            }
        }
    }
    
    // MARK: - Title View
    private var titleView: some View {
        Text(categoryTitle)
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding()
    }
    
    // MARK: - Content View
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            loadingView
        } else if let errorMessage = viewModel.errorMessage {
            errorView(message: errorMessage)
        } else if viewModel.categoryContents.isEmpty {
            emptyStateView
        } else {
            contentsListView
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        ProgressView("Cargando contenidos...")
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
    }
    
    // MARK: - Error View
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            
            Text("Error al cargar contenidos")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.largeTitle)
                .foregroundColor(.gray)
            
            Text("No se encontraron contenidos")
                .font(.headline)
            
            Text("No hay contenidos disponibles en esta categoría todavía. ¡Vuelve más tarde!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
    }
    
    // MARK: - Contents List View
    private var contentsListView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(viewModel.categoryContents.count) contenidos encontrados")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ForEach(viewModel.categoryContents) { content in
                NavigationLink(destination: ContentDetailView(content: content)) {
                    contentCard(for: content)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Content Card
    private func contentCard(for content: Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let thumbnailUrl = content.thumbnailUrl, !thumbnailUrl.isEmpty {
                AsyncImage(url: URL(string: thumbnailUrl)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(16/9, contentMode: .fill)
                            .overlay(
                                ProgressView()
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(16/9, contentMode: .fill)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.white)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 120)
                .cornerRadius(8)
            }
            
            Text(content.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(content.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            contentMetadata(for: content)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Content Metadata
    private func contentMetadata(for content: Content) -> some View {
        HStack {
            if content.isPremium {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("Premium")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if content.videoUrl != nil {
                Image(systemName: "play.circle")
                    .foregroundColor(.indigo)
                Text("Video")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if content.tendencia > 0 {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.green)
                Text("Tendencia")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - ContentDetailView
struct ContentDetailView: View {
    let content: Content
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Thumbnail o imagen de portada
                if let thumbnailUrl = content.thumbnailUrl, !thumbnailUrl.isEmpty {
                    AsyncImage(url: URL(string: thumbnailUrl)) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .aspectRatio(16/9, contentMode: .fill)
                                .overlay(
                                    ProgressView()
                                )
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity)
                                .clipped()
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .aspectRatio(16/9, contentMode: .fill)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.white)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(height: 200)
                    .padding(.top, 60)
                }
                
                // Título y descripción
                VStack(alignment: .leading, spacing: 12) {
                    Text(content.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if content.isPremium {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Contenido Premium")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    Text(content.description)
                        .font(.body)
                        .padding(.vertical, 8)
                    
                    if let videoUrl = content.videoUrl, !videoUrl.isEmpty {
                        NavigationLink {
                            TopicsView(
                                contentID: Int(content.id) ?? 0,
                                contentTitle: content.title,
                                user: getUserId(),
                                contentImageURL: content.thumbnailUrl ?? "",
                                shouldRefresh: .constant(false)
                            )
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true)
                        } label: {
                            Text("Acceder al Curso")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.indigo)
                                .cornerRadius(12)
                        }
                        .padding(.top, 16)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(content.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
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
            }
        }
    }
}

// Helper para obtener el ID del usuario actual
private func getUserId() -> Int {
    let keychain = KeychainSwift()
    if let userIdString = keychain.get("userID"), let userId = Int(userIdString) {
        return userId
    }
    return 0 // Valor por defecto si no se puede obtener
}

// MARK: - Preview
struct CategoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CategoryDetailView(categoryId: "1", categoryTitle: "Ansiedad")
        }
    }
} 
