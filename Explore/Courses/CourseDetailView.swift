//
//  CourseDetailView.swift
//  Phil
//
//  Created on 16/03/24.
//

import SwiftUI
import KeychainSwift

struct CourseDetailView: View {
    // MARK: - Properties
    let course: Course
    @Environment(\.presentationMode) var presentationMode
    @State private var shouldRefresh = false
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                courseImageView
                courseDetailsView
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
    }
    
    // MARK: - Course Image View
    private var courseImageView: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .aspectRatio(16/9, contentMode: .fill)
            .overlay(courseImageContent)
    }
    
    // MARK: - Course Image Content
    @ViewBuilder
    private var courseImageContent: some View {
        if let imageUrl = course.imageUrl, !imageUrl.isEmpty {
            // Si hay una URL de imagen, intentar cargarla
            AsyncImage(url: URL(string: imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    placeholderImage
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            // Si no hay URL, mostrar un placeholder
            placeholderImage
        }
    }
    
    // MARK: - Placeholder Image
    private var placeholderImage: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
            .foregroundColor(.gray.opacity(0.5))
    }
    
    // MARK: - Course Details View
    private var courseDetailsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text(course.title)
                .font(.title)
                .fontWeight(.bold)
            
            // Lessons and duration
            courseMetadataView
                .padding(.vertical, 8)
            
            // Description
            Text("Acerca de este curso")
                .font(.headline)
                .padding(.top, 8)
            
            Text(course.description)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Enroll button
            enrollButton
                .padding(.top, 20)
        }
        .padding()
    }
    
    // MARK: - Course Metadata View
    private var courseMetadataView: some View {
        HStack {
            Image(systemName: "book.closed")
                .foregroundColor(.indigo)
            Text("\(course.lessons) \(course.lessons == 1 ? "lección" : "lecciones")")
                .foregroundColor(.indigo)
            
            Spacer()
        }
    }
    
    // MARK: - Enroll Button
    private var enrollButton: some View {
        NavigationLink {
            // Al pulsar el botón, navegamos a la vista de temas del curso
            TopicsView(
                contentID: Int(course.id) ?? 0,
                contentTitle: course.title,
                user: getUserId(),
                contentImageURL: course.imageUrl ?? "",
                shouldRefresh: $shouldRefresh
            )
            .navigationBarBackButtonHidden(true) // Ocultar el botón de navegación predeterminado
            .navigationBarHidden(true) // Ocultar la barra de navegación completamente
        } label: {
            Text("Acceder al Curso")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.indigo)
                .cornerRadius(12)
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
}

// MARK: - Preview
struct CourseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CourseDetailView(
                course: Course(
                    id: "1",
                    title: "Fundamentos de SwiftUI",
                    description: "Aprende los fundamentos de SwiftUI y crea hermosas aplicaciones iOS.",
                    lessons: 12,
                    imageUrl: nil,
                    categoryId: "1"
                )
            )
        }
    }
} 
