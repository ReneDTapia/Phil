import Foundation
import Alamofire
import KeychainSwift
import SwiftUI

// Timeframe para el gráfico
enum Timeframe: Int {
    case week = 0
    case month = 1
    case all = 2
}

// Categoría para el gráfico
enum WellnessCategory {
    case depression, anxiety, relationships, wellbeing
    
    var color: Color {
        switch self {
        case .depression:
            return Color(red: 0.3, green: 0.3, blue: 0.8) // Azul violáceo
        case .anxiety:
            return Color(red: 0.6, green: 0.2, blue: 0.8) // Púrpura
        case .relationships:
            return Color(red: 0.4, green: 0.2, blue: 0.6) // Púrpura oscuro
        case .wellbeing:
            return Color(red: 0.5, green: 0.3, blue: 0.7) // Lavanda
        }
    }
    
    var name: String {
        switch self {
        case .depression:
            return "Depresión"
        case .anxiety:
            return "Ansiedad"
        case .relationships:
            return "Relaciones"
        case .wellbeing:
            return "Bienestar"
        }
    }
}

// Datos para el gráfico
struct ChartData: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let category: WellnessCategory
}

// Modelo de Logro
struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let emoji: String
    let progressPercent: Double
}

// Modelo para las estadísticas del usuario
struct UserStats: Codable {
    var sessionsCount: Int
    var streakCount: Int
    var hoursCount: Int
    
    enum CodingKeys: String, CodingKey {
        case sessionsCount = "sessions_count"
        case streakCount = "streak_count"
        case hoursCount = "hours_count"
    }
    
    init(sessionsCount: Int, streakCount: Int, hoursCount: Int) {
        self.sessionsCount = sessionsCount
        self.streakCount = streakCount
        self.hoursCount = hoursCount
    }
    
    // Inicializador personalizado para la decodificación
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Intentar decodificar usando snake_case
        do {
            sessionsCount = try container.decode(Int.self, forKey: .sessionsCount)
            streakCount = try container.decode(Int.self, forKey: .streakCount)
            hoursCount = try container.decode(Int.self, forKey: .hoursCount)
        } catch {
            // Si falla, intenta con nombres camelCase directamente
            let alternativeContainer = try decoder.container(keyedBy: AlternativeCodingKeys.self)
            sessionsCount = try alternativeContainer.decodeIfPresent(Int.self, forKey: .sessionsCount) ?? 0
            streakCount = try alternativeContainer.decodeIfPresent(Int.self, forKey: .streakCount) ?? 0
            hoursCount = try alternativeContainer.decodeIfPresent(Int.self, forKey: .hoursCount) ?? 0
        }
    }
    
    // Claves alternativas para la decodificación
    private enum AlternativeCodingKeys: String, CodingKey {
        case sessionsCount, streakCount, hoursCount
    }
}

// Modelo para la información del usuario
struct User2: Codable {
    let email: String
    let username: String
    let bio: String
    let goal: String
    let profileImageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case email
        case username
        case bio
        case goal
        case profileImageURL = "profile_image_url"
    }
    
    init(email: String, username: String, bio: String, goal: String, profileImageURL: String? = nil) {
        self.email = email
        self.username = username
        self.bio = bio
        self.goal = goal
        self.profileImageURL = profileImageURL
    }
    
    // Inicializador personalizado para la decodificación
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Intentar decodificar con manejo de errores individuales
        do {
            email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        } catch {
            print("Error decoding email: \(error)")
            email = ""
        }
        
        do {
            username = try container.decodeIfPresent(String.self, forKey: .username) ?? ""
        } catch {
            print("Error decoding username: \(error)")
            username = ""
        }
        
        do {
            bio = try container.decodeIfPresent(String.self, forKey: .bio) ?? ""
        } catch {
            print("Error decoding bio: \(error)")
            bio = ""
        }
        
        do {
            goal = try container.decodeIfPresent(String.self, forKey: .goal) ?? ""
        } catch {
            print("Error decoding goal: \(error)")
            goal = ""
        }
        
        do {
            profileImageURL = try container.decodeIfPresent(String.self, forKey: .profileImageURL)
        } catch {
            print("Error decoding profileImageURL: \(error)")
            profileImageURL = nil
        }
    }
}

// Punto de datos para cada categoría de bienestar
struct WellnessPoint: Codable {
    let label: String
    let value: Double
    
    enum CodingKeys: String, CodingKey {
        case label, value
    }
    
    init(label: String, value: Double) {
        self.label = label
        self.value = value
    }
    
    // Inicializador personalizado para la decodificación
    init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            label = try container.decodeIfPresent(String.self, forKey: .label) ?? ""
            
            // Manejar diferentes tipos de valor (Int, Double, String)
            if let valueDouble = try? container.decode(Double.self, forKey: .value) {
                value = valueDouble
            } else if let valueInt = try? container.decode(Int.self, forKey: .value) {
                value = Double(valueInt)
            } else if let valueString = try? container.decode(String.self, forKey: .value),
                      let parsedValue = Double(valueString) {
                value = parsedValue
            } else {
                value = 0.0
            }
        } catch {
            print("Error decodificando WellnessPoint: \(error)")
            label = ""
            value = 0.0
        }
    }
}

// Modelo para los datos de bienestar por período
struct WellnessDataResponse: Codable {
    let depression: [WellnessPoint]
    let anxiety: [WellnessPoint]
    let relationships: [WellnessPoint]
    let wellbeing: [WellnessPoint]
    
    enum CodingKeys: String, CodingKey {
        case depression, anxiety, relationships, wellbeing
    }
    
    init(depression: [WellnessPoint], anxiety: [WellnessPoint], relationships: [WellnessPoint], wellbeing: [WellnessPoint]) {
        self.depression = depression
        self.anxiety = anxiety
        self.relationships = relationships
        self.wellbeing = wellbeing
    }
    
    // Inicializador personalizado para la decodificación
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Intentar decodificar con manejo de errores individuales
        do {
            depression = try container.decodeIfPresent([WellnessPoint].self, forKey: .depression) ?? []
        } catch {
            print("Error decoding depression: \(error)")
            depression = []
        }
        
        do {
            anxiety = try container.decodeIfPresent([WellnessPoint].self, forKey: .anxiety) ?? []
        } catch {
            print("Error decoding anxiety: \(error)")
            anxiety = []
        }
        
        do {
            relationships = try container.decodeIfPresent([WellnessPoint].self, forKey: .relationships) ?? []
        } catch {
            print("Error decoding relationships: \(error)")
            relationships = []
        }
        
        do {
            wellbeing = try container.decodeIfPresent([WellnessPoint].self, forKey: .wellbeing) ?? []
        } catch {
            print("Error decoding wellbeing: \(error)")
            wellbeing = []
        }
    }
}

// Modelo para logros de la API
struct AchievementResponse: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let emojiCode: String
    let progress: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case emojiCode = "emoji_code"
        case progress
    }
}

class UserViewModel: ObservableObject {
    @Published var user: User2?
    @Published var stats: UserStats?
    @Published var wellnessDataResponse: WellnessDataResponse?
    @Published var achievementsResponse: [AchievementResponse] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    // Propiedades privadas para estadísticas del usuario
    private var _sessionsCount: Int = 42
    private var _streakCount: Int = 8
    private var _hoursCount: Int = 16
    
    // Propiedades computadas para acceder a los valores
    var sessionsCount: Int { return _sessionsCount }
    var streakCount: Int { return _streakCount }
    var hoursCount: Int { return _hoursCount }
    
    // Propiedades y variables privadas
    private var userId: Int
    private var _wellnessData: [ChartData] = []
    private var _achievements: [Achievement] = []
    
    let baseURL = "http://44.219.217.34:3004/api/auth"
    
    init(userId: Int){
        self.userId = userId
    }
    
    // Método privado para actualizar los contadores basados en stats
    private func updateStatCounts() {
        if let stats = self.stats {
            self._sessionsCount = stats.sessionsCount
            self._streakCount = stats.streakCount
            self._hoursCount = stats.hoursCount
        }
        self.objectWillChange.send()
    }

    func fetchUserInfo() {
        isLoading = true
        let endpoint = "\(baseURL)/GetUsersInfo/\(userId)"
        
        let keychain = KeychainSwift()
        
        // Define el encabezado con el token Bearer
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(keychain.get("userToken") ?? "notoken")"
        ]
        
        // DESCOMENTAR PARA PRODUCCIÓN: Usar la API real
        /*
        AF.request(endpoint, method: .get, headers: headers).responseData { response in
            DispatchQueue.main.async {
                self.isLoading = false
                switch response.result {
                case .success(let data):
                    do {
                        let user = try JSONDecoder().decode(User2.self, from: data)
                        self.user = user
                    } catch {
                        self.errorMessage = "Error al decodificar datos: \(error.localizedDescription)"
                    }
                case .failure(let error):
                    self.errorMessage = "Error en la solicitud: \(error.localizedDescription)"
                }
            }
        }
        */
        
        // SIMULACIÓN: Simular la respuesta para desarrollo
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            self.isLoading = false
            self.user = User2(
                email: "usuario@ejemplo.com",
                username: "John Doe",
                bio: "Mental health enthusiast | Mindfulness practitioner",
                goal: "Working on reducing anxiety and improving sleep 💪"
            )
        }
    }
    
    func deleteUser() {
        let endpoint = "\(baseURL)/deleteUser/\(userId)"
        
        let keychain = KeychainSwift()
        
        // Define el encabezado con el token Bearer
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(keychain.get("userToken") ?? "notoken")"
        ]
        
        AF.request(endpoint, method: .delete, headers: headers).response { response in
            DispatchQueue.main.async {
                switch response.result {
                case .success:
                    // Eliminación exitosa, puedes realizar cualquier acción adicional si es necesario
                    print("Usuario eliminado correctamente")
                case .failure(let error):
                    // Error al eliminar el usuario
                    print("Error al eliminar el usuario: \(error.localizedDescription)")
                }
            }
        }
    }

    func updateUsername(newUsername: String) {
        let endpoint = "\(baseURL)/PutUsername/\(userId)"
        let parameters = ["newUsername": newUsername]
        
        let keychain = KeychainSwift()
        
        // Define el encabezado con el token Bearer
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(keychain.get("userToken") ?? "notoken")"
        ]

        AF.request(endpoint, method: .put, parameters: parameters, encoder: JSONParameterEncoder.default).response { response in
            DispatchQueue.main.async {
                if let error = response.error {
                    self.errorMessage = "Error en la solicitud: \(error.localizedDescription)"
                    return
                }

                if let httpResponse = response.response, httpResponse.statusCode == 200 {
                    self.fetchUserInfo()
                } else {
                    self.errorMessage = "Error al actualizar el usuario"
                }
            }
        }
    }
    
    // MARK: - New API Methods
    
    func fetchUserStats() {
        isLoading = true
        errorMessage = nil
        let endpoint = "\(baseURL)/GetUserStats/\(userId)"
        
        let keychain = KeychainSwift()
        
        // Define el encabezado con el token Bearer
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(keychain.get("userToken") ?? "notoken")"
        ]
        
        // DESCOMENTAR PARA PRODUCCIÓN: Usar la API real
        /*
        AF.request(endpoint, method: .get, headers: headers).responseData { response in
            DispatchQueue.main.async {
                self.isLoading = false
                switch response.result {
                case .success(let data):
                    do {
                        // Para depuración, imprimir el JSON recibido
                        if let jsonString = String(data: data, encoding: .utf8) {
                            print("Respuesta recibida para estadísticas: \(jsonString)")
                        }
                        
                        // Usar decoder personalizado para manejar diferentes formatos
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        
                        // Intentar decodificar en la estructura UserStats
                        let stats = try decoder.decode(UserStats.self, from: data)
                        self.stats = stats
                        self.updateStatCounts() // Actualizar propiedades privadas
                    } catch {
                        print("Error de decodificación: \(error)")
                        
                        // Si hay error, intentar decodificar como diccionario primero
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                                // Extraer valores del diccionario y crear manualmente el objeto UserStats
                                let sessionsCount = json["sessions_count"] as? Int ?? json["sessionsCount"] as? Int ?? 0
                                let streakCount = json["streak_count"] as? Int ?? json["streakCount"] as? Int ?? 0
                                let hoursCount = json["hours_count"] as? Int ?? json["hoursCount"] as? Int ?? 0
                                
                                self.stats = UserStats(
                                    sessionsCount: sessionsCount,
                                    streakCount: streakCount,
                                    hoursCount: hoursCount
                                )
                                self.updateStatCounts() // Actualizar propiedades privadas
                            } else {
                                // Valores de respaldo en caso de error
                                self.errorMessage = "Error al decodificar estadísticas: \(error.localizedDescription)"
                                self.stats = UserStats(
                                    sessionsCount: 42,
                                    streakCount: 8,
                                    hoursCount: 16
                                )
                                self.updateStatCounts() // Actualizar propiedades privadas
                            }
                        } catch {
                            self.errorMessage = "Error al procesar datos de estadísticas: \(error.localizedDescription)"
                            self.stats = UserStats(
                                sessionsCount: 42,
                                streakCount: 8,
                                hoursCount: 16
                            )
                            self.updateStatCounts() // Actualizar propiedades privadas
                        }
                    }
                case .failure(let error):
                    self.errorMessage = "Error en la solicitud de estadísticas: \(error.localizedDescription)"
                    // Usar datos de muestra en caso de error
                    self.stats = UserStats(
                        sessionsCount: 42,
                        streakCount: 8,
                        hoursCount: 16
                    )
                    self.updateStatCounts() // Actualizar propiedades privadas
                }
            }
        }
        */
        
        // SIMULACIÓN: Simular la respuesta para desarrollo
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            self.isLoading = false
            self.stats = UserStats(
                sessionsCount: 42,
                streakCount: 8,
                hoursCount: 16
            )
            
            // Actualizar propiedades privadas manualmente
            self._sessionsCount = 42
            self._streakCount = 8
            self._hoursCount = 16
            
            // Notificar observadores
            self.objectWillChange.send()
        }
    }
    
    func updateTimeframe(_ timeframe: Timeframe) {
        isLoading = true
        errorMessage = nil
        
        // Guardar selección actual
        UserDefaults.standard.set(timeframe.rawValue, forKey: "selectedTimeframe")
        
        let period = timeframe == .week ? "weekly" : "monthly"
        let endpoint = "\(baseURL)/GetWellnessData/\(userId)/\(period)"
        
        let keychain = KeychainSwift()
        
        // Define el encabezado con el token Bearer
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(keychain.get("userToken") ?? "notoken")"
        ]
        
        // DESCOMENTAR PARA PRODUCCIÓN: Usar la API real
        /*
        AF.request(endpoint, method: .get, headers: headers).responseData { response in
            DispatchQueue.main.async {
                self.isLoading = false
                switch response.result {
                case .success(let data):
                    do {
                        // Para depuración, imprimir el JSON recibido
                        if let jsonString = String(data: data, encoding: .utf8) {
                            print("Respuesta recibida para wellness data: \(jsonString)")
                        }
                        
                        // Usar decoder personalizado para manejar diferentes formatos
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        
                        let wellnessData = try decoder.decode(WellnessDataResponse.self, from: data)
                        self.wellnessDataResponse = wellnessData
                        self._wellnessData = self.convertWellnessResponseToChartData(wellnessData)
                        self.objectWillChange.send()
                    } catch {
                        print("Error de decodificación wellness: \(error)")
                        
                        // Si falla la decodificación, usar datos de muestra
                        self.errorMessage = "Error al decodificar datos de bienestar: \(error.localizedDescription)"
                        self._wellnessData = self.sampleChartData(for: timeframe)
                        self.objectWillChange.send()
                    }
                case .failure(let error):
                    self.errorMessage = "Error en la solicitud de datos de bienestar: \(error.localizedDescription)"
                    self._wellnessData = self.sampleChartData(for: timeframe)
                    self.objectWillChange.send()
                }
            }
        }
        */
        
        // SIMULACIÓN: Simular la respuesta para desarrollo
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            
            self.isLoading = false
            
            // Generar datos de simulación basados en el timeframe
            let mockDepression = timeframe == .week ? 
                [
                    WellnessPoint(label: "Lun", value: 60),
                    WellnessPoint(label: "Mar", value: 40),
                    WellnessPoint(label: "Mie", value: 30),
                    WellnessPoint(label: "Jue", value: 45),
                    WellnessPoint(label: "Vie", value: 55),
                    WellnessPoint(label: "Sab", value: 35),
                    WellnessPoint(label: "Dom", value: 28)
                ] : [
                    WellnessPoint(label: "Sem 1", value: 45),
                    WellnessPoint(label: "Sem 2", value: 38),
                    WellnessPoint(label: "Sem 3", value: 42),
                    WellnessPoint(label: "Sem 4", value: 30)
                ]
            
            let mockAnxiety = timeframe == .week ? 
                [
                    WellnessPoint(label: "Lun", value: 70),
                    WellnessPoint(label: "Mar", value: 65),
                    WellnessPoint(label: "Mie", value: 55),
                    WellnessPoint(label: "Jue", value: 40),
                    WellnessPoint(label: "Vie", value: 30),
                    WellnessPoint(label: "Sab", value: 25),
                    WellnessPoint(label: "Dom", value: 35)
                ] : [
                    WellnessPoint(label: "Sem 1", value: 60),
                    WellnessPoint(label: "Sem 2", value: 50),
                    WellnessPoint(label: "Sem 3", value: 35),
                    WellnessPoint(label: "Sem 4", value: 40)
                ]
            
            let mockRelationships = timeframe == .week ? 
                [
                    WellnessPoint(label: "Lun", value: 35),
                    WellnessPoint(label: "Mar", value: 40),
                    WellnessPoint(label: "Mie", value: 45),
                    WellnessPoint(label: "Jue", value: 50),
                    WellnessPoint(label: "Vie", value: 55),
                    WellnessPoint(label: "Sab", value: 60),
                    WellnessPoint(label: "Dom", value: 65)
                ] : [
                    WellnessPoint(label: "Sem 1", value: 40),
                    WellnessPoint(label: "Sem 2", value: 50),
                    WellnessPoint(label: "Sem 3", value: 55),
                    WellnessPoint(label: "Sem 4", value: 65)
                ]
            
            let mockWellbeing = timeframe == .week ? 
                [
                    WellnessPoint(label: "Lun", value: 30),
                    WellnessPoint(label: "Mar", value: 35),
                    WellnessPoint(label: "Mie", value: 45),
                    WellnessPoint(label: "Jue", value: 50),
                    WellnessPoint(label: "Vie", value: 60),
                    WellnessPoint(label: "Sab", value: 70),
                    WellnessPoint(label: "Dom", value: 75)
                ] : [
                    WellnessPoint(label: "Sem 1", value: 35),
                    WellnessPoint(label: "Sem 2", value: 45),
                    WellnessPoint(label: "Sem 3", value: 60),
                    WellnessPoint(label: "Sem 4", value: 70)
                ]
            
            // Crear un objeto WellnessDataResponse con los datos de simulación
            self.wellnessDataResponse = WellnessDataResponse(
                depression: mockDepression,
                anxiety: mockAnxiety,
                relationships: mockRelationships,
                wellbeing: mockWellbeing
            )
            
            // Actualizar los datos de gráfico
            self._wellnessData = self.convertWellnessResponseToChartData(self.wellnessDataResponse!)
            self.objectWillChange.send()
        }
    }
    
    func fetchAchievements() {
        isLoading = true
        errorMessage = nil
        
        let endpoint = "\(baseURL)/GetAchievements/\(userId)"
        
        let keychain = KeychainSwift()
        
        // Define el encabezado con el token Bearer
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(keychain.get("userToken") ?? "notoken")"
        ]
        
        // DESCOMENTAR PARA PRODUCCIÓN: Usar la API real
        /*
        AF.request(endpoint, method: .get, headers: headers).responseData { response in
            DispatchQueue.main.async {
                self.isLoading = false
                switch response.result {
                case .success(let data):
                    do {
                        // Para depuración, imprimir el JSON recibido
                        if let jsonString = String(data: data, encoding: .utf8) {
                            print("Respuesta recibida para logros: \(jsonString)")
                        }
                        
                        // Usar decoder personalizado para manejar diferentes formatos
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        
                        let achievements = try decoder.decode([AchievementResponse].self, from: data)
                        self.achievementsResponse = achievements
                        
                        // Convertir las respuestas a objetos Achievement
                        self._achievements = self.achievementsResponse.map { response in
                            Achievement(
                                title: response.title,
                                description: response.description,
                                emoji: response.emojiCode,
                                progressPercent: response.progress
                            )
                        }
                        self.objectWillChange.send()
                    } catch {
                        print("Error de decodificación logros: \(error)")
                        
                        // Datos de muestra como respaldo
                        self.errorMessage = "Error al decodificar logros: \(error.localizedDescription)"
                        self.setDefaultAchievements()
                    }
                case .failure(let error):
                    self.errorMessage = "Error en la solicitud de logros: \(error.localizedDescription)"
                    // Usar datos de muestra en caso de error
                    self.setDefaultAchievements()
                }
            }
        }
        */
        
        // SIMULACIÓN: Simular la respuesta para desarrollo
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self = self else { return }
            
            self.isLoading = false
            // Usar datos de muestra para simulación
            self.achievementsResponse = [
                AchievementResponse(
                    id: 1,
                    title: "Consistency Champion",
                    description: "Completed activities for 7 consecutive days",
                    emojiCode: "🔥",
                    progress: 100
                ),
                AchievementResponse(
                    id: 2,
                    title: "Mindfulness Explorer",
                    description: "Completed 5 mindfulness sessions",
                    emojiCode: "🧘",
                    progress: 80
                ),
                AchievementResponse(
                    id: 3,
                    title: "Sleep Improver",
                    description: "Tracked sleep for 10 days",
                    emojiCode: "💤",
                    progress: 60
                )
            ]
            
            // Convertir las respuestas a objetos Achievement
            self._achievements = self.achievementsResponse.map { response in
                Achievement(
                    title: response.title,
                    description: response.description,
                    emoji: response.emojiCode,
                    progressPercent: response.progress
                )
            }
            self.objectWillChange.send()
        }
    }
    
    // Método privado para establecer logros predeterminados
    private func setDefaultAchievements() {
        self.achievementsResponse = [
            AchievementResponse(
                id: 1,
                title: "Consistency Champion",
                description: "Completed activities for 7 consecutive days",
                emojiCode: "🔥",
                progress: 100
            ),
            AchievementResponse(
                id: 2,
                title: "Mindfulness Explorer",
                description: "Completed 5 mindfulness sessions",
                emojiCode: "🧘",
                progress: 80
            ),
            AchievementResponse(
                id: 3,
                title: "Sleep Improver",
                description: "Tracked sleep for 10 days",
                emojiCode: "💤",
                progress: 60
            )
        ]
        
        // Convertir las respuestas a objetos Achievement
        self._achievements = self.achievementsResponse.map { response in
            Achievement(
                title: response.title,
                description: response.description,
                emoji: response.emojiCode,
                progressPercent: response.progress
            )
        }
        self.objectWillChange.send()
    }
    
    // Método privado para convertir WellnessDataResponse a ChartData
    private func convertWellnessResponseToChartData(_ response: WellnessDataResponse) -> [ChartData] {
        var result: [ChartData] = []
        
        // Agregar datos de depresión
        for point in response.depression {
            result.append(ChartData(label: point.label, value: point.value, category: .depression))
        }
        
        // Agregar datos de ansiedad
        for point in response.anxiety {
            result.append(ChartData(label: point.label, value: point.value, category: .anxiety))
        }
        
        // Agregar datos de relaciones
        for point in response.relationships {
            result.append(ChartData(label: point.label, value: point.value, category: .relationships))
        }
        
        // Agregar datos de bienestar
        for point in response.wellbeing {
            result.append(ChartData(label: point.label, value: point.value, category: .wellbeing))
        }
        
        return result
    }
    
    // MARK: - Computed Properties para compatibilidad con la UI existente
    
    var currentTimeframe: Timeframe {
        let storedValue = UserDefaults.standard.integer(forKey: "selectedTimeframe")
        return Timeframe(rawValue: storedValue) ?? .week
    }
    
    // Datos del gráfico por categorías
    var wellnessData: [ChartData] {
        // Devolver los datos almacenados en la variable privada
        if !_wellnessData.isEmpty {
            return _wellnessData
        }
        
        // Si no hay datos aún, usar la muestra basada en la currentTimeframe
        return sampleChartData(for: currentTimeframe)
    }
    
    // Logros de muestra
    var achievements: [Achievement] {
        // Devolver los logros almacenados en la variable privada
        if !_achievements.isEmpty {
            return _achievements
        }
        
        // Si no hay datos aún, crear logros de muestra
        return [
            Achievement(
                title: "Consistency Champion",
                description: "Completed activities for 7 consecutive days",
                emoji: "🔥",
                progressPercent: 100
            ),
            Achievement(
                title: "Mindfulness Explorer",
                description: "Completed 5 mindfulness sessions",
                emoji: "🧘",
                progressPercent: 80
            ),
            Achievement(
                title: "Sleep Improver",
                description: "Tracked sleep for 10 days",
                emoji: "💤",
                progressPercent: 60
            )
        ]
    }
    
    // Función para generar datos de muestra para el gráfico
    private func sampleChartData(for timeframe: Timeframe) -> [ChartData] {
        switch timeframe {
        case .week:
            return [
                ChartData(label: "Lun", value: 60, category: .depression),
                ChartData(label: "Mar", value: 30, category: .anxiety),
                ChartData(label: "Mie", value: 45, category: .wellbeing),
                ChartData(label: "Jue", value: 75, category: .relationships),
                ChartData(label: "Vie", value: 40, category: .depression),
                ChartData(label: "Sab", value: 55, category: .anxiety),
                ChartData(label: "Dom", value: 65, category: .wellbeing)
            ]
        case .month:
            return [
                ChartData(label: "Sem 1", value: 65, category: .depression),
                ChartData(label: "Sem 2", value: 70, category: .anxiety),
                ChartData(label: "Sem 3", value: 55, category: .wellbeing),
                ChartData(label: "Sem 4", value: 45, category: .relationships)
            ]
        default:
            return []
        }
    }
}
