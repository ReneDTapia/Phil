import SwiftUI
import Foundation
import Alamofire

class TopicsViewModel: ObservableObject{
    @Published var resultTopics: [TopicsModel] = []
    @Published var topicStatus: [TopicsStatusModel] = []
     

    func getTopics(contentIDVM: Int, userIDVM: Int) async{
        
        do {
            let topics: [TopicsModel] = try await APIClient.get(path: "getTopics/\(userIDVM)/\(contentIDVM)")
            DispatchQueue.main.async {
                self.resultTopics = topics
            }
        } catch {
            print("Error fetching topics: \(error)")
        }
        
    }

    
    func getTopicsStatus(topicIDVM: Int, userIDVM: Int) async {
        
        do {
            let topicsStatus: [TopicsStatusModel] = try await APIClient.get(path: "getUserResult/\(userIDVM)/\(topicIDVM)")
            DispatchQueue.main.async {
                self.topicStatus = topicsStatus
            }
        } catch {
            print("Error fetching topics status: \(error)")
        }
        
    }

    
    func UpdateDone(user: Int, topic: Int, done: Bool) {
        
        let url = "https://philbackend.onrender.com/api/auth/UpdateDone"

        // Define el cuerpo de la petición
        let parameters: [String: Any] = [
            "user": user,
            "topic": topic,
            "done": done
        ]

        // ejecutamos con alamofire
        AF.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default).response { response in
            switch response.result {
            case .success:
                print("Message registered successfully!")
            case .failure(let error):
                print("Error registering message: \(error)")
            }
        }
    }
    
    func postTopic(user: Int, topic: Int) {
        
        let url = "https://philbackend.onrender.com/api/auth/CheckTopic"

        // Define el cuerpo de la petición
        let parameters: [String: Any] = [
            "user": user,
            "topic": topic,
            "done": true
        ]

        // ejecutamos con alamofire
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { response in
            switch response.result {
            case .success:
                print("Message registered successfully!")
            case .failure(let error):
                print("Error registering message: \(error)")
            }
        }
    }
}
