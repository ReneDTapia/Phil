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
    let userID: Int
}

class AuthService {
    static let shared = AuthService()
    
    private let baseURL = "https://phill-api.diloensenas.org/api/auth/"
    //private let baseURL = "http://localhost:3004/api/auth/"
    
    func register(email: String, username: String, password: String, confirmPassword: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        let url = "\(baseURL)/register"
        let parameters = [
            "email": email,
            "username": username,
            "password": password,
            "confirmPassword": confirmPassword
        ]

        print("Password: \(password)")
        print("Confirm Password: \(parameters["confirmPassword"] ?? "N/A")")

        AF.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default).responseDecodable(of: LoginResponse.self) { response in
            print("Response: \(response)")
            switch response.result {
            case .success(let data):
                // Registro exitoso y token obtenido
                completion(.success(data))
            case .failure:
                // Verificamos el código de estado
                if let data = response.data, let serverResponse = String(data: data, encoding: .utf8) {
                    // Otros códigos de estado
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: serverResponse])))
                } else {
                    let unknownError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown registration error"])
                    completion(.failure(unknownError))
                }
            }
        }
    }

    
    func login(username: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        let url = "\(baseURL)/login"
        let parameters = [
            "loginIdentifier": username,
            "password": password
        ]
        
        // Print login credentials for debugging
        print("==== LOGIN REQUEST DETAILS ====")
        print("URL: \(url)")
        print("Username/Email: \(username)")
        print("Password: \(password)")
        print("Full parameters being sent: \(parameters)")
        print("===============================")
        
        AF.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default).responseDecodable(of: LoginResponse.self) { response in  
            print("Response: \(response)")
            
            // Print raw response data for debugging
            if let data = response.data, let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw response data: \(rawResponse)")
            }
            
            switch response.result {
            case .success(let data):
                print("Login successful - User ID: \(data.userID)")
                print("Token received: \(data.token.prefix(15))...")  // Only print first part of token for security
                LoginViewModel().userID = data.userID
                completion(.success(data))
            case .failure(let error):
                print("Login failed with error: \(error.localizedDescription)")
                if let statusCode = response.response?.statusCode {
                    print("Status code: \(statusCode)")
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
    
    func logout() {
        TokenHelper.deleteToken()
    }

    
}

enum CustomError: Error {
    case unauthorized
    case forbidden
}
