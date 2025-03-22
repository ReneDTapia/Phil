import SwiftUI
import Foundation
import Alamofire
import KeychainSwift

class TopicsViewModel: ObservableObject {
    @Published var resultTopics: [TopicsModel] = []
    @Published var topicStatus: [TopicsStatusModel] = []
     
    // Método que coincide con la nueva firma utilizada en TopicsView
    func getTopics(userID: Int, contentID: Int) async throws {
        try await getTopics(contentIDVM: contentID, userIDVM: userID)
    }

    func getTopics(contentIDVM: Int, userIDVM: Int) async throws {
        let topics: [TopicsModel] = try await APIClient.get(path: "getTopics/\(userIDVM)/\(contentIDVM)")
        
        print("Raw API Response for topics:")
        
        for topic in topics {
            print("""
            Topic: \(topic.topic)
            Title: \(topic.title)
            Raw thumbnail_url: '\(topic.thumbnail_url)'
            """)
        }
        
        DispatchQueue.main.async {
            self.resultTopics = topics
            
            print("----------- Topics Fetched -----------")
            print("Number of topics: \(topics.count)")
            for topic in topics {
                print("""
                    Topic ID: \(topic.topic)
                    Title: \(topic.title)
                    Thumbnail URL: \(topic.thumbnail_url)
                    Is Done: \(topic.done ?? false)
                    ------------------------------------
                    """)
            }
        }
    }

    func getTopicsStatus(topicIDVM: Int, userIDVM: Int) async throws {
        let topicsStatus: [TopicsStatusModel] = try await APIClient.get(path: "getUserResult/\(userIDVM)/\(topicIDVM)")
        DispatchQueue.main.async {
            self.topicStatus = topicsStatus
        }
    }

    func UpdateDone(user: Int, topic: Int, done: Bool) {
        let url = "https://phill-api.diloensenas.org/api/auth/UpdateDone"
        
        let parameters: [String: Any] = [
            "user": user,
            "topic": topic,
            "done": done
        ]

        var headers: HTTPHeaders = []
        if let token = getToken() {
            headers.add(name: "Authorization", value: "Bearer \(token)")
        }
        
        AF.request(url,
                  method: .put,
                  parameters: parameters,
                  encoding: JSONEncoding.default,
                  headers: headers)
        .validate()
        .responseData { response in
            switch response.result {
            case .success:
                print("Topic status updated successfully!")
                if let index = self.resultTopics.firstIndex(where: { $0.topic == topic }) {
                    DispatchQueue.main.async {
                        self.resultTopics[index].done = done
                    }
                }
            case .failure(let error):
                print("Error updating topic status: \(error)")
            }
        }
    }
    
    func getToken() -> String? {
        let keychain = KeychainSwift()
        if let token = keychain.get("userToken"), !TokenHelper.isTokenExpired(token: token) {
            return token
        }
        return nil
    }
    
    func postTopic(user: Int, topic: Int) {
        let url = "https://phill-api.diloensenas.org/api/auth/CheckTopic"

        let parameters: [String: Any] = [
            "user": user,
            "topic": topic,
            "done": true
        ]

        var headers: HTTPHeaders = []
        if let token = getToken() {
            headers.add(name: "Authorization", value: "Bearer \(token)")
        }
        
        AF.request(url,
                  method: .post,
                  parameters: parameters,
                  encoding: JSONEncoding.default,
                  headers: headers)
        .validate()
        .responseData { response in
            switch response.result {
            case .success:
                print("Topic checked successfully!")
                if let index = self.resultTopics.firstIndex(where: { $0.topic == topic }) {
                    DispatchQueue.main.async {
                        self.resultTopics[index].done = true
                    }
                }
            case .failure(let error):
                print("Error checking topic: \(error)")
            }
        }
    }
}
