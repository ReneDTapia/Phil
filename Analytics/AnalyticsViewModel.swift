//
//  AnalyticsViewModel.swift
//  Phil
//
//  Created by Leonardo García Ledezma on 07/11/23.
//

import Foundation
import Alamofire

class AnalyticsViewModel : ObservableObject {
    @Published var emotions: [AnalyticsModel] = []
    
    
    func getUserEmotions(userId: Int, days: Int) {
        APIClient.getN(path: "getUserEmotions/\(userId)/\(days)") { (result: Result<[AnalyticsModel], AFError>) in
            switch result {
            case .success(let fetchedEmotions):
                self.emotions = fetchedEmotions
                let topEmotions = self.topEmotions(emotions: self.emotions)

            case .failure(let error):
                print(error)
            }
        }
    }

    func topEmotions(emotions: [AnalyticsModel]) -> [String] {
        var emotionCounts = [String: Int]()
        for emotion in emotions {
            emotionCounts[emotion.emotion] = (emotionCounts[emotion.emotion] ?? 0) + 1
        }
        let sortedEmotions = emotionCounts.sorted { $0.value > $1.value }
        let topEmotions = Array(sortedEmotions.prefix(5)) // Limita la salida a las 5 emociones principales
        return topEmotions.map { $0.key }
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
