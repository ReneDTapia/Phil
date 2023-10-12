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
    
    func register(email: String, username: String, password: String, confirmPassword: String, completion: @escaping (Result<String, Error>) -> Void) {
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
                completion(.success(data.token))
            case .failure:
                // Verificamos el código de estado
                if response.response?.statusCode == 201 {
                    // Esto no debería suceder si la respuesta es un error, pero lo mantenemos por precaución
                    completion(.success("Token not found but registration successful."))
                } else if let data = response.data, let serverResponse = String(data: data, encoding: .utf8) {
                    // Otros códigos de estado
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: serverResponse])))
                } else {
                    let unknownError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown registration error"])
                    completion(.failure(unknownError))
                }
            }
        }
    }

    
    func login(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = "\(baseURL)/login"
        let parameters = [
            "username": username,
            "password": password
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default).responseDecodable(of: LoginResponse.self) { response in  print("Response: \(response)")
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
