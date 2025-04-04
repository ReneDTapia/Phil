import Foundation
import Alamofire
import KeychainSwift

// Estructuras para el nuevo endpoint
struct UserStatsResponse: Codable {
    let userId: Int
    let username: String
    let totalTopicsCompleted: Int
    let categoriesStats: [StatsByCategory]
    let completedCategories: [CategoryInfo]
}

struct CategoryInfo: Codable, Identifiable {
    let id: Int
    let name: String
    let emoji: String?
    let color: String
}

struct StatsByCategory: Codable, Identifiable {
    var id: Int { category.id }
    let category: CategoryInfo
    let topicsCompleted: Int
}


class UserViewModel: ObservableObject {
    @Published var user: User2?
    @Published var userStats: UserStatsResponse?
    @Published var errorMessage: String?
    
    private var userId: Int
    let baseURL = "https://phill-api.diloensenas.org/api/auth"
    
    init(userId: Int) {
        self.userId = userId
    }
    
    func fetchUserInfo() {
        let endpoint = "\(baseURL)/user-stats/\(userId)"
        
        let keychain = KeychainSwift()
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(keychain.get("userToken") ?? "")"
        ]
        
        AF.request(endpoint, method: .get, headers: headers)
            .responseData { [weak self] response in
                DispatchQueue.main.async {
                    switch response.result {
                    case .success(let data):
                        do {
                            let stats = try JSONDecoder().decode(UserStatsResponse.self, from: data)
                            self?.userStats = stats
                            // Crear un User2 compatible con la vista existente
                            self?.user = User2(
                                email: "", // El nuevo endpoint no incluye email
                                username: stats.username
                            )
                        } catch {
                            self?.errorMessage = "Error al decodificar datos: \(error.localizedDescription)"
                        }
                    case .failure(let error):
                        self?.errorMessage = "Error en la solicitud: \(error.localizedDescription)"
                    }
                }
            }
    }
    
    func updateUsername(newUsername: String) {
        let endpoint = "\(baseURL)/PutUsername/\(userId)"
        let parameters = ["newUsername": newUsername]
        
        let keychain = KeychainSwift()
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(keychain.get("userToken") ?? "")"
        ]
        
        AF.request(endpoint,
                  method: .put,
                  parameters: parameters,
                  encoder: JSONParameterEncoder.default,
                  headers: headers)
            .response { [weak self] response in
                DispatchQueue.main.async {
                    if let error = response.error {
                        self?.errorMessage = "Error en la solicitud: \(error.localizedDescription)"
                        return
                    }
                    
                    if let httpResponse = response.response, httpResponse.statusCode == 200 {
                        self?.fetchUserInfo()
                    } else {
                        self?.errorMessage = "Error al actualizar el usuario"
                    }
                }
            }
    }
    
    func deleteUser() {
        let endpoint = "\(baseURL)/deleteUser/\(userId)"
        
        let keychain = KeychainSwift()
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(keychain.get("userToken") ?? "")"
        ]
        
        AF.request(endpoint, method: .delete, headers: headers)
            .validate()
            .response { [weak self] response in
                DispatchQueue.main.async {
                    if let statusCode = response.response?.statusCode {
                        switch statusCode {
                        case 200, 204:
                            // Éxito - la cuenta se eliminó correctamente
                            print("Usuario eliminado correctamente")
                            NotificationCenter.default.post(name: NSNotification.Name("UserDeleted"), object: nil)
                        default:
                            self?.errorMessage = "Error al eliminar la cuenta. Por favor, intenta más tarde."
                        }
                    } else if let error = response.error {
                        self?.errorMessage = "Error de conexión: \(error.localizedDescription)"
                    }
                }
            }
    }
}
