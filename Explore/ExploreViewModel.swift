//
//  ExploreViewModel.swift
//  Phil
//
//  Created on 21/03/24.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Models

struct Course: Identifiable {
    let id: String
    let title: String
    let description: String
    let lessons: Int
    let imageUrl: String?
    let categoryId: String
}

struct Category: Identifiable {
    let id: String
    let title: String
    let emoji: String?
    let color: Color
    
    // Initializer for API response
    init(from apiResponse: CategoryResponse) {
        self.id = String(apiResponse.id)
        // Usar el nombre exacto del API (en español)
        self.title = apiResponse.name
        self.emoji = apiResponse.emoji
        
        // Convert color string to SwiftUI Color
        switch apiResponse.color.lowercased() {
        case "pink":
            self.color = Color.pink.opacity(0.3)
        case "blue":
            self.color = Color.blue.opacity(0.3)
        case "orange":
            self.color = Color.orange.opacity(0.3)
        case "cyan":
            self.color = Color.cyan.opacity(0.3)
        case "red":
            self.color = Color.red.opacity(0.3)
        case "purple":
            self.color = Color.purple.opacity(0.3)
        case "green":
            self.color = Color.green.opacity(0.3)
        case "light blue":
            self.color = Color(red: 0.5, green: 0.8, blue: 1.0).opacity(0.3)
        default:
            self.color = Color.gray.opacity(0.3)
        }
    }
    
    // Initializer for manual creation (for preview/mock data)
    init(id: String, title: String, emoji: String, color: Color) {
        self.id = id
        self.title = title
        self.emoji = emoji
        self.color = color
    }
}

// Model matching the API response
struct CategoryResponse: Codable, Identifiable {
    let id: Int
    let name: String
    let emoji: String?
    let color: String
}

// Modelo para la respuesta de API de cursos
struct CourseResponse: Codable, Identifiable {
    let id: Int
    let title: String
    let thumbnail_url: String?
    let description: String
    let tendencia: Int
    let topicCount: Int
    let categoryName: String
    
    // Convertir a nuestro modelo Course
    func toCourse() -> Course {
        return Course(
            id: String(id),
            title: title,
            description: description,
            lessons: topicCount,
            imageUrl: thumbnail_url,
            categoryId: categoryName
        )
    }
}

// Modelo para la respuesta de API de contenidos
struct ContentResponse: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let video_url: String?
    let thumbnail_url: String?
    let is_premium: Bool
    let author_id: Int
    let category_id: Int
    let created_at: String
    let updated_at: String
    let tendencia: Int
    
    // Convertir a nuestro modelo Content
    func toContent() -> Content {
        return Content(
            id: String(id),
            title: title,
            description: description,
            videoUrl: video_url,
            thumbnailUrl: thumbnail_url,
            isPremium: is_premium,
            authorId: String(author_id),
            categoryId: String(category_id),
            tendencia: tendencia
        )
    }
}

struct Content: Identifiable {
    let id: String
    let title: String
    let description: String
    let videoUrl: String?
    let thumbnailUrl: String?
    let isPremium: Bool
    let authorId: String
    let categoryId: String
    let tendencia: Int
}

// MARK: - ViewModel

class ExploreViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var trendingCourses: [Course] = []
    @Published var recommendedCourses: [Course] = []
    @Published var categories: [Category] = []
    @Published var categoryContents: [Content] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchResults: [Course] = []
    @Published var username: String = ""
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        // Get username from UserDefaults or other storage
        if let savedUsername = UserDefaults.standard.string(forKey: "username") {
            self.username = savedUsername
        }
        
        // Solo cargamos datos mock si es necesario para cursos
        loadMockCourses()
        
        // No cargar automáticamente las categorías al inicio
        // fetchCategories() - Esto se llamará desde la vista cuando aparezca
    }
    
    // MARK: - Public Methods
    
    /// Fetches all courses and categories
    func fetchCourses() {
        isLoading = true
        
        Task {
            do {
                print("📚 Iniciando obtención de cursos del API...")
                let courseResponses: [CourseResponse] = try await APIClient.get(path: "topTrending")
                
                print("📚 Se obtuvieron \(courseResponses.count) cursos del API")
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    // Convertir respuestas API a nuestro modelo Course
                    let courses = courseResponses.map { $0.toCourse() }
                    
                    // Asignar a trendingCourses
                    self.trendingCourses = courses
                    
                    // Por ahora, también asignamos los mismos cursos a recommendedCourses
                    // En el futuro, se podría implementar otro endpoint para cursos recomendados
                    self.recommendedCourses = courses
                    
                    self.isLoading = false
                    print("📚 Cursos cargados correctamente desde la API")
                }
            } catch {
                print("❌ Error al obtener cursos: \(error)")
                print("❌ Detalles del error: \(error.localizedDescription)")
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.errorMessage = "Error al obtener cursos: \(error.localizedDescription)"
                    
                    // Cargar datos mock solo si hay error
                    print("📚 Cargando datos mock como respaldo")
                    self.loadMockCourses()
                    
                    self.isLoading = false
                }
            }
        }
    }
    
    /// Fetches categories from the API
    func fetchCategories() {
        isLoading = true
        print("📊 Iniciando obtención de categorías del API...")
        
        Task {
            do {
                // Usar la ruta correcta para obtener categorías
                print("📊 Llamando al endpoint: \(APIClient.baseURL)getCategories")
                let categoryResponses: [CategoryResponse] = try await APIClient.get(path: "getCategories")
                
                print("📊 Se obtuvieron \(categoryResponses.count) categorías del API")
                for (index, category) in categoryResponses.enumerated() {
                    print("📊 Categoría \(index+1): id=\(category.id), nombre=\(category.name), emoji=\(category.emoji ?? "nil"), color=\(category.color)")
                }
                
                // Convert API responses to our Category model
                let fetchedCategories = categoryResponses.map { response -> Category in
                    // Crear la categoría preservando el nombre exacto del API
                    let category = Category(from: response)
                    print("📊 Categoría procesada: id=\(category.id), título=\(category.title), emoji=\(category.emoji ?? "nil")")
                    return category
                }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    print("📊 Actualizando modelo con \(fetchedCategories.count) categorías")
                    
                    // Solo actualizamos con datos API si tenemos resultados
                    if !fetchedCategories.isEmpty {
                        self.categories = fetchedCategories
                        print("📊 Categorías API cargadas correctamente")
                    } else {
                        print("⚠️ API no devolvió categorías, manteniendo datos existentes")
                        if self.categories.isEmpty {
                            self.loadMockCategories()
                            print("⚠️ Cargando categorías mock ya que no hay categorías disponibles")
                        }
                    }
                    
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.errorMessage = "Error al obtener categorías: \(error.localizedDescription)"
                    self.isLoading = false
                    print("❌ Error al obtener categorías: \(error)")
                    print("❌ Detalles del error: \(error.localizedDescription)")
                    
                    // Verificar categorías actuales
                    if self.categories.isEmpty {
                        // Fall back to mock data if API fails and we have no categories
                        print("📊 Usando datos de prueba como respaldo ya que no hay categorías")
                        self.loadMockCategories()
                    } else {
                        print("📊 Manteniendo categorías existentes a pesar del error")
                    }
                }
            }
        }
    }
    
    /// Fetches courses filtered by category
    /// - Parameter categoryId: The ID of the category to filter by
    func fetchCoursesByCategory(categoryId: String) {
        isLoading = true
        print("🔍 Fetching courses for category ID: \(categoryId)")
        
        // Si no hay cursos cargados, primero los obtenemos
        if trendingCourses.isEmpty {
            Task {
                do {
                    print("📚 Cargando cursos antes de filtrar por categoría...")
                    let courseResponses: [CourseResponse] = try await APIClient.get(path: "topTrending")
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        
                        // Convertir respuestas API a nuestro modelo Course
                        let allCourses = courseResponses.map { $0.toCourse() }
                        
                        // Si la categoría es "all", mostrar todos los cursos
                        if categoryId == "all" {
                            self.trendingCourses = allCourses
                            self.recommendedCourses = allCourses
                        } else {
                            // Filtrar por categoría
                            self.trendingCourses = allCourses.filter { course in
                                // Comparamos la categoría directamente o el nombre en minúsculas
                                return course.categoryId.lowercased() == categoryId.lowercased() ||
                                       self.categories.first(where: { String($0.id) == categoryId })?.title.lowercased() == course.categoryId.lowercased()
                            }
                            
                            self.recommendedCourses = self.trendingCourses
                        }
                        
                        self.isLoading = false
                        print("🔍 Filtered to \(self.trendingCourses.count) courses for category \(categoryId)")
                    }
                } catch {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.errorMessage = "Error al obtener cursos: \(error.localizedDescription)"
                        
                        // Cargar y filtrar datos mock en caso de error
                        self.loadMockData()
                        
                        if categoryId != "all" {
                            self.trendingCourses = self.trendingCourses.filter { course in
                                return course.categoryId.lowercased() == categoryId.lowercased() || 
                                       self.categories.first(where: { String($0.id) == categoryId })?.title.lowercased() == course.categoryId.lowercased()
                            }
                            
                            self.recommendedCourses = self.trendingCourses
                        }
                        
                        self.isLoading = false
                    }
                }
            }
        } else {
            // Si ya tenemos cursos, simplemente filtramos los existentes
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                let allCourses = self.trendingCourses + self.recommendedCourses
                
                if categoryId != "all" {
                    self.trendingCourses = allCourses.filter { course in
                        return course.categoryId.lowercased() == categoryId.lowercased() || 
                               self.categories.first(where: { String($0.id) == categoryId })?.title.lowercased() == course.categoryId.lowercased()
                    }
                    
                    self.recommendedCourses = []
                } else {
                    // Recargar todos los cursos desde la API
                    Task {
                        do {
                            let courseResponses: [CourseResponse] = try await APIClient.get(path: "topTrending")
                            
                            DispatchQueue.main.async { [weak self] in
                                guard let self = self else { return }
                                
                                let allCourses = courseResponses.map { $0.toCourse() }
                                self.trendingCourses = allCourses
                                self.recommendedCourses = []
                                self.isLoading = false
                            }
                        } catch {
                            self.loadMockCourses()
                            self.isLoading = false
                        }
                    }
                }
                
                self.isLoading = false
                print("🔍 Filtered to \(self.trendingCourses.count) courses for category \(categoryId)")
            }
        }
    }
    
    /// Searches for courses matching the query
    /// - Parameter query: The search query
    func searchCourses(query: String) {
        isLoading = true
        
        Task {
            do {
                // Intentamos obtener los cursos de la API si aún no tenemos
                if self.trendingCourses.isEmpty {
                    let courseResponses: [CourseResponse] = try await APIClient.get(path: "topTrending")
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        
                        // Convertir respuestas API a nuestro modelo Course
                        let allCourses = courseResponses.map { $0.toCourse() }
                        
                        // Guardamos todos los cursos
                        self.trendingCourses = allCourses
                        
                        // Filtramos para la búsqueda
                        self.filterCoursesForSearch(query: query)
                    }
                } else {
                    // Si ya tenemos cursos, simplemente filtramos
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.filterCoursesForSearch(query: query)
                    }
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    // Si hay error, cargamos datos mock
                    if self.trendingCourses.isEmpty {
                        self.loadMockCourses()
                    }
                    
                    // Y luego filtramos
                    self.filterCoursesForSearch(query: query)
                }
            }
        }
    }
    
    private func filterCoursesForSearch(query: String) {
        let lowercasedQuery = query.lowercased()
        self.searchResults = self.trendingCourses.filter { course in
            course.title.lowercased().contains(lowercasedQuery) ||
            course.description.lowercased().contains(lowercasedQuery)
        }
        self.isLoading = false
    }
    
    /// Fetches contents for a specific category
    /// - Parameter categoryId: The ID of the category to fetch contents for
    func fetchContentsByCategory(categoryId: String) {
        isLoading = true
        print("📚 Iniciando obtención de contenidos para la categoría ID: \(categoryId)")
        
        Task {
            do {
                // Usar la ruta correcta para obtener contenidos por categoría
                let path = "getContentsByCategory/\(categoryId)"
                print("📚 Llamando al endpoint: \(APIClient.baseURL)\(path)")
                
                let contentResponses: [ContentResponse] = try await APIClient.get(path: path)
                
                print("📚 Se obtuvieron \(contentResponses.count) contenidos del API para la categoría \(categoryId)")
                
                // Convertir respuestas API a nuestro modelo Content
                let contents = contentResponses.map { $0.toContent() }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.categoryContents = contents
                    self.isLoading = false
                    print("📚 Contenidos de categoría cargados correctamente desde la API")
                }
            } catch {
                print("❌ Error al obtener contenidos: \(error)")
                print("❌ Detalles del error: \(error.localizedDescription)")
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    // Verificar si el error está relacionado con "No contents found for this category"
                    let errorString = error.localizedDescription
                    if errorString.contains("No contents found") || 
                       errorString.contains("No contents found for this category") ||
                       errorString.contains("404") {
                        // Tratar como caso vacío (no como error)
                        print("ℹ️ No hay contenidos para esta categoría, mostrando vista vacía")
                        self.categoryContents = []
                        self.errorMessage = nil
                    } else {
                        // Para otros errores, mantener el mensaje de error
                        self.errorMessage = "Error al obtener contenidos: \(error.localizedDescription)"
                        self.categoryContents = []
                    }
                    
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Loads mock data for testing
    private func loadMockData() {
        loadMockCourses()
        loadMockCategories()
    }
    
    /// Loads only mock course data
    private func loadMockCourses() {
        // Mock trending courses
        trendingCourses = [
            Course(id: "1", title: "Superar la Ansiedad Social", description: "Aprende técnicas para manejar la ansiedad social y ganar confianza en situaciones sociales.", lessons: 8, imageUrl: nil, categoryId: "anxiety"),
            Course(id: "2", title: "Mindfulness para Principiantes", description: "Comienza tu viaje de mindfulness con prácticas diarias simples para reducir el estrés.", lessons: 12, imageUrl: nil, categoryId: "stress"),
            Course(id: "3", title: "Construyendo Hábitos Saludables", description: "Desarrolla hábitos sostenibles que mejoren tu bienestar mental y físico.", lessons: 10, imageUrl: nil, categoryId: "self-esteem"),
            Course(id: "4", title: "Comunicación Efectiva", description: "Mejora tus habilidades de comunicación para construir mejores relaciones.", lessons: 6, imageUrl: nil, categoryId: "relationships")
        ]
        
        // Mock recommended courses
        recommendedCourses = [
            Course(id: "5", title: "Manejo del Estrés", description: "Técnicas prácticas para manejar el estrés en tu vida diaria.", lessons: 9, imageUrl: nil, categoryId: "stress"),
            Course(id: "6", title: "Inteligencia Emocional", description: "Desarrolla tus habilidades de conciencia y regulación emocional.", lessons: 7, imageUrl: nil, categoryId: "self-esteem"),
            Course(id: "7", title: "Mejora del Sueño", description: "Estrategias para mejorar la calidad y duración de tu sueño.", lessons: 5, imageUrl: nil, categoryId: "sleep"),
            Course(id: "8", title: "Manejando la Depresión", description: "Enfoques basados en evidencia para lidiar con síntomas de depresión.", lessons: 10, imageUrl: nil, categoryId: "depression")
        ]
    }
    
    /// Loads mock categories for testing
    private func loadMockCategories() {
        // Si ya tenemos categorías del API, no sobrescribimos con datos mock
        if !categories.isEmpty {
            print("⚠️ No se cargan categorías mock porque ya hay \(categories.count) categorías existentes")
            return
        }
        
        print("📊 Cargando categorías mock")
        categories = [
            Category(id: "anxiety", title: "Ansiedad", emoji: "🧠", color: Color.pink.opacity(0.3)),
            Category(id: "depression", title: "Depresión", emoji: "💙", color: Color.blue.opacity(0.3)),
            Category(id: "stress", title: "Estrés", emoji: "😓", color: Color.orange.opacity(0.3)),
            Category(id: "sleep", title: "Sueño", emoji: "😴", color: Color.cyan.opacity(0.3)),
            Category(id: "relationships", title: "Relaciones", emoji: "❤️", color: Color.red.opacity(0.3)),
            Category(id: "self-esteem", title: "Autoestima", emoji: "🌟", color: Color.purple.opacity(0.3))
        ]
    }
}
