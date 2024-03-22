import Foundation
import Alamofire

class UserViewModel: ObservableObject {
    @Published var user: User2?
    @Published var errorMessage: String?
    private var userId: Int
    init(userId: Int){
        self.userId = userId
    }
    let baseURL = "http://44.219.217.34:3004/api/auth"

    func fetchUserInfo() {
        let endpoint = "\(baseURL)/GetUsersInfo/\(userId)"
        
        AF.request(endpoint, method: .get).responseData { response in
            DispatchQueue.main.async {
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
    }

    func updateUsername(newUsername: String) {
        let endpoint = "\(baseURL)/PutUsername/\(userId)"
        let parameters = ["newUsername": newUsername]

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
}
