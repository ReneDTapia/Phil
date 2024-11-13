import Alamofire
import SwiftUI
import Foundation
import KeychainSwift

class APIClient {
    
    static let baseURL = "https://phill-api.diloensenas.org/api/auth/"
//     static let baseURL = "http://localhost:5005/api/auth/"
    
    static func getToken() -> String? {
        let keychain = KeychainSwift()
        if let token = keychain.get("userToken"), !TokenHelper.isTokenExpired(token: token) {
            return token
        }
        return nil
    }

    // Función general para GET
    static func get<T: Decodable>(path: String) async throws -> T {
        var headers: HTTPHeaders = []
        if let token = getToken() {
            headers.add(name: "Authorization", value: "Bearer \(token)")
        }
        let request = AF.request(baseURL + path, method: .get, headers: headers).validate()
        return try await request.serializingDecodable(T.self).value
    }

    // Función general para POST
    static func post(path: String, parameters: Parameters?) async throws -> Data? {
        var headers: HTTPHeaders = []
        if let token = getToken() {
            headers.add(name: "Authorization", value: "Bearer \(token)")
        }
        let request = AF.request(baseURL + path, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        let response = try await request.serializingData().result.get()
        return response
    }

    // Función general para PUT
    static func put<T: Decodable>(path: String, parameters: Parameters?) async throws -> T {
        var headers: HTTPHeaders = []
        if let token = getToken() {
            headers.add(name: "Authorization", value: "Bearer \(token)")
        }
        let request = AF.request(baseURL + path, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate()
        return try await request.serializingDecodable(T.self).value
    }
    
    // Función general para DELETE
    static func delete(path: String) async throws {
        var headers: HTTPHeaders = []
        if let token = getToken() {
            headers.add(name: "Authorization", value: "Bearer \(token)")
        }
        let request = AF.request(baseURL + path, method: .delete, headers: headers).validate()
        _ = try await request.serializingData().result.get()
    }

    // Funciones no asíncronas

    // Función general para GET
    static func getN<T: Decodable>(path: String, completion: @escaping (Result<T, AFError>) -> Void) {
        var headers: HTTPHeaders = []
        if let token = getToken() {
            headers.add(name: "Authorization", value: "Bearer \(token)")
        }
        AF.request(baseURL + path, method: .get, headers: headers).validate().responseDecodable(of: T.self) { response in
            completion(response.result)
        }
    }
    
    // Función general para POST
    static func postN(path: String, parameters: Parameters?, completion: @escaping (AFDataResponse<Data?>) -> Void) {
        var headers: HTTPHeaders = []
        if let token = getToken() {
            headers.add(name: "Authorization", value: "Bearer \(token)")
        }
        AF.request(baseURL + path, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { response in
            completion(response)
        }
    }
                                                                                                                                                                                                                        
    // Función general para PUT
    static func putN<T: Decodable>(path: String, parameters: Parameters?, completion: @escaping (Result<T, AFError>) -> Void) {
        var headers: HTTPHeaders = []
        if let token = getToken() {
            headers.add(name: "Authorization", value: "Bearer \(token)")
        }
        AF.request(baseURL + path, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseDecodable(of: T.self) { response in
            completion(response.result)
        }
    }
    
    // Función general para DELETE
    static func deleteN<T: Decodable>(path: String, completion: @escaping (Result<T, AFError>) -> Void) {
        var headers: HTTPHeaders = []
        if let token = getToken() {
            headers.add(name: "Authorization", value: "Bearer \(token)")
        }
        AF.request(baseURL + path, method: .delete, headers: headers).validate().responseDecodable(of: T.self) { response in
            completion(response.result)
        }
    }
}
