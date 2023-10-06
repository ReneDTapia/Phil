//
//  AuthService.swift
//  Phil
//
//  Created by Rene  on 05/10/23.
//

import Foundation
import Alamofire

struct LoginResponse: Decodable {
    let token: String
}

class AuthService {
    static let shared = AuthService()
    
    private let baseURL = "http://localhost:5000/api/auth"
    
    func register(email: String, username: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = "\(baseURL)/register"
        let parameters = [
            "email": email,
            "username": username,
            "password": password
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default).response { response in
            switch response.result {
            case .success:
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func login(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = "\(baseURL)/login"
        let parameters = [
            "username": username,
            "password": password
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default).responseDecodable(of: LoginResponse.self) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data.token))
            case .failure(let error):
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case 401:
                        // Token no autorizado o token expirado
                        completion(.failure(CustomError.unauthorized))
                    case 403:
                        // Acceso prohibido
                        completion(.failure(CustomError.forbidden))
                    default:
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
}

enum CustomError: Error {
    case unauthorized
    case forbidden
}
