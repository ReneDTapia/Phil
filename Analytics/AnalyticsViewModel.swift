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
    
    func getAnal(completion: @escaping () -> Void) {
        APIClient.getN(path: "getUserAnal/1") { (result: Result<[AnalyticsModel], AFError>) in
            switch result {
            case .success(let fetchedEmotions):
                self.emotions = fetchedEmotions
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func topEmotions(count: Int) -> [AnalyticsModel] {
        return Array(emotions.sorted(by: { $0.Percentage > $1.Percentage }).prefix(count))
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
