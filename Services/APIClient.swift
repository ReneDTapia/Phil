import Alamofire
import SwiftUI
import Foundation

class APIClient {
    
    static let baseURL = "https://philbackend.onrender.com/api/auth/"
    
    // Función general para GET
    static func get<T: Decodable>(path: String, completion: @escaping (Result<T, AFError>) -> Void) {
        AF.request(baseURL + path, method: .get).validate().responseDecodable(of: T.self) { response in
            completion(response.result)
        }
    }
    
    // funcion general pa post
    static func post(path: String, parameters: Parameters?, completion: @escaping (AFDataResponse<Data?>) -> Void) {
        AF.request(baseURL + path, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { response in
            completion(response)
        }
    }


    
    // Función general para PUT
    static func put<T: Decodable>(path: String, parameters: Parameters?, completion: @escaping (Result<T, AFError>) -> Void) {
        AF.request(baseURL + path, method: .put, parameters: parameters, encoding: JSONEncoding.default).validate().responseDecodable(of: T.self) { response in
            completion(response.result)
        }
    }
    
    // Función general para DELETE
    static func delete<T: Decodable>(path: String, completion: @escaping (Result<T, AFError>) -> Void) {
        AF.request(baseURL + path, method: .delete).validate().responseDecodable(of: T.self) { response in
            completion(response.result)
        }
    }
}
