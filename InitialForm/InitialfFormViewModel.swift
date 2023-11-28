import Foundation
import SwiftUI
import Alamofire
import Combine

class InitialFormViewModel: ObservableObject {
    @Published var formGroups: [[InitialFormModel]] = []
    @Published var selectedButtons: [[Int]] = Array(repeating: [], count: 4)
    @Published var selectedCount = 0
    @Published var selectedValues: [[Double]] = []
    
    @Published var answers: [Int: Double] = [:]
    @Published var isFirstTime = true

    func updateAnswer(for questionId: Int, with value: Double) {
        answers[questionId] = value
    }
    
    func getForm() {
        guard let url = URL(string: "\(APIClient.baseURL)getForm") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        addToken(to: &request)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                if let data = data {
                    let forms = try JSONDecoder().decode([InitialFormModel].self, from: data)
                    DispatchQueue.main.async {
                        self.formGroups = [forms]
                    }
                } else {
                    print("No data")
                }
            } catch {
                print(error)
            }
        }.resume()
    }

    private func addToken(to request: inout URLRequest) {
        if let token = APIClient.getToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
    
    func postAnswers(user_id: Int) {
        guard let url = URL(string: "\(APIClient.baseURL)postUserForm") else {
            print("URL inválida")
            return
        }
        
        let body = answers.map { ["Users_id": user_id, "Cuestionario_id": $0.key, "Percentage": $0.value] }
        let finalBody = try? JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = finalBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        addToken(to: &request)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error al enviar las respuestas: \(error)")
            } else if let data = data {
                let str = String(data: data, encoding: .utf8)
                print("Respuesta recibida: \(str ?? "")")
            }
        }.resume()
    }

    func updateAnswers(user_id: Int) {
        guard let url = URL(string: "\(APIClient.baseURL)updateUserForm/\(user_id)") else {
            print("URL inválida")
            return
        }
        
        let body = answers.map { ["Users_id": user_id, "Cuestionario_id": $0.key, "Percentage": $0.value] }
        let finalBody = try? JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = finalBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        addToken(to: &request)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error al actualizar las respuestas: \(error)")
            } else if let data = data {
                let str = String(data: data, encoding: .utf8)
                print("Respuesta recibida: \(str ?? "")")
            }
        }.resume()
    }

    func deleteAnswers(user_id: Int) async throws {
        guard let url = URL(string: "\(APIClient.baseURL)deleteUserForm/\(user_id)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        addToken(to: &request)
        
        let _: () = try await withCheckedThrowingContinuation { continuation in
            AF.request(request).validate().response { response in
                switch response.result {
                case .success(let data):
                    if let data = data {
                        let str = String(data: data, encoding: .utf8)
                        print("Respuesta recibida: \(str ?? "")")
                    }
                    continuation.resume(returning: ())
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
