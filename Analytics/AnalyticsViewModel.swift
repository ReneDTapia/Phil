//
//  AnalyticsViewModel.swift
//  Phil
//
//  Created by Leonardo García Ledezma on 07/11/23.
//

import Foundation
import Alamofire
import Combine

class AnalyticsViewModel : ObservableObject {
    @Published var emotions: [AnalyticsModel] = []
    
    
    func getUserEmotions(userId: Int, days: Int) -> Future<[AnalyticsModel], AFError> {
        return Future { promise in
            APIClient.getN(path: "getUserEmotions/\(userId)/\(days)") { (result: Result<[AnalyticsModel], AFError>) in
                switch result {
                case .success(let fetchedEmotions):
                    self.emotions = fetchedEmotions
                    let topEmotions = self.topEmotions(emotions: self.emotions)
                    promise(.success(topEmotions))
                case .failure(let error):
                    print(error)
                    promise(.failure(error))
                }
            }
            print(self.emotions.count)
        }
    }

    func topEmotions(emotions: [AnalyticsModel]) -> [AnalyticsModel] {
        let sortedEmotions = emotions.sorted { Double($0.emotionpercentage ?? "0") ?? 0 > Double($1.emotionpercentage ?? "0") ?? 0 }
        let topEmotions = Array(sortedEmotions.prefix(5)) // Limita la salida a las 5 emociones principales
        return topEmotions
    }

    
}






//class APIClient {
//    
//    static let baseURL = "http://localhost:5005/api/auth/"
//    
//    // Función general para GET
//    static func get<T: Decodable>(path: String, completion: @escaping (Result<T, AFError>) -> Void) {
//        AF.request(baseURL + path, method: .get).validate().responseDecodable(of: T.self) { response in
//            completion(response.result)
//        }
//    }
//}

// func getUserEmotions(userId: Int, days: Int, completion: @escaping ([AnalyticsModel]) -> Void) {
    //     APIClient.getN(path: "getUserEmotions/\(userId)/\(days)") { (result: Result<[AnalyticsModel], AFError>) in
    //         switch result {
    //         case .success(let fetchedEmotions):
    //             completion(fetchedEmotions)
    //         case .failure(let error):
    //             print(error)
    //         }
    //     }
    // }
// func getAnal(userId: Int) {
    //     APIClient.getN(path: "getUserAnal/\(userId)") { (result: Result<[AnalyticsModel], AFError>) in
    //         switch result {
    //         case .success(let fetchedEmotions):
    //             self.emotions = fetchedEmotions
    //         case .failure(let error):
    //             print(error)
    //         }
    //     }
    // }
