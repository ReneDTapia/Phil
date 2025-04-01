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

// MARK: - ViewModel

class ExploreViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var trendingCourses: [Course] = []
    @Published var recommendedCourses: [Course] = []
    @Published var categories: [Category] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchResults: [Course] = []
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        // Solo cargamos datos mock si es necesario para cursos
        // Pero ahora no cargaremos categorías mock al inicializar
        loadMockCourses()
        
        // Intentamos obtener categorías del API inmediatamente
        fetchCategories()
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
            Course(id: "1", title: "Overcoming Social Anxiety", description: "Learn techniques to manage social anxiety and build confidence in social situations.", lessons: 8, imageUrl: nil, categoryId: "anxiety"),
            Course(id: "2", title: "Mindfulness for Beginners", description: "Start your mindfulness journey with simple daily practices for stress reduction.", lessons: 12, imageUrl: nil, categoryId: "stress"),
            Course(id: "3", title: "Building Healthy Habits", description: "Develop sustainable habits that improve your mental and physical wellbeing.", lessons: 10, imageUrl: nil, categoryId: "self-esteem"),
            Course(id: "4", title: "Effective Communication", description: "Enhance your communication skills to build better relationships.", lessons: 6, imageUrl: nil, categoryId: "relationships")
        ]
        
        // Mock recommended courses
        recommendedCourses = [
            Course(id: "5", title: "Stress Management", description: "Practical techniques to manage stress in your daily life.", lessons: 9, imageUrl: nil, categoryId: "stress"),
            Course(id: "6", title: "Emotional Intelligence", description: "Develop your emotional awareness and regulation skills.", lessons: 7, imageUrl: nil, categoryId: "self-esteem"),
            Course(id: "7", title: "Sleep Improvement", description: "Strategies to improve your sleep quality and duration.", lessons: 5, imageUrl: nil, categoryId: "sleep"),
            Course(id: "8", title: "Managing Depression", description: "Evidence-based approaches to cope with depression symptoms.", lessons: 10, imageUrl: nil, categoryId: "depression")
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
            Category(id: "anxiety", title: "Anxiety", emoji: "🧠", color: Color.pink.opacity(0.3)),
            Category(id: "depression", title: "Depression", emoji: "💙", color: Color.blue.opacity(0.3)),
            Category(id: "stress", title: "Stress", emoji: "😓", color: Color.orange.opacity(0.3)),
            Category(id: "sleep", title: "Sleep", emoji: "😴", color: Color.cyan.opacity(0.3)),
            Category(id: "relationships", title: "Relationships", emoji: "❤️", color: Color.red.opacity(0.3)),
            Category(id: "self-esteem", title: "Self-Esteem", emoji: "🌟", color: Color.purple.opacity(0.3))
        ]
    }
}
