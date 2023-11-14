//
//  APIClient.swift
//  Phil
//
//  Created by Rene  on 09/11/23.
//

import Alamofire
import SwiftUI
import Foundation

class APIClient {
    
//    static let baseURL = "https://philbackend.onrender.com/api/auth/"
    static let baseURL = "http://localhost:5005/api/auth/"
    
    // Función general para GET
    static func get<T: Decodable>(path: String) async throws -> T {
        let request = AF.request(baseURL + path, method: .get).validate()
        return try await request.serializingDecodable(T.self).value
    }

    
    // funcion general pa post
    static func post(path: String, parameters: Parameters?) async throws -> Data? {
        let request = AF.request(baseURL + path, method: .post, parameters: parameters, encoding: JSONEncoding.default)
        let response = try await request.serializingData().result.get()
        return response
    }



    
    // Función general para PUT
    static func put<T: Decodable>(path: String, parameters: Parameters?) async throws -> T {
        let request = AF.request(baseURL + path, method: .put, parameters: parameters, encoding: JSONEncoding.default).validate()
        return try await request.serializingDecodable(T.self).value
    }
    
    
    //asinc para delete
    static func delete(path: String) async throws {
        let request = AF.request(baseURL + path, method: .delete).validate()
        _ = try await request.serializingData().result.get()
    }


    //estandar para funciones no asincronas JAJAJAJAJJA.
    
    
    
// Función general para GET
    static func getN<T: Decodable>(path: String, completion: @escaping (Result<T, AFError>) -> Void) {
        AF.request(baseURL + path, method: .get).validate().responseDecodable(of: T.self) { response in
            completion(response.result)
        }
    }
    
    // funcion general pa post
    static func postN(path: String, parameters: Parameters?, completion: @escaping (AFDataResponse<Data?>) -> Void) {
        AF.request(baseURL + path, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { response in
            completion(response)
        }
    }


    
    // Función general para PUT
    static func putN<T: Decodable>(path: String, parameters: Parameters?, completion: @escaping (Result<T, AFError>) -> Void) {
        AF.request(baseURL + path, method: .put, parameters: parameters, encoding: JSONEncoding.default).validate().responseDecodable(of: T.self) { response in
            completion(response.result)
        }
    }
    
    // Función general para DELETE
    static func deleteN<T: Decodable>(path: String, completion: @escaping (Result<T, AFError>) -> Void) {
        AF.request(baseURL + path, method: .delete).validate().responseDecodable(of: T.self) { response in
            completion(response.result)
        }
    }

}
