import SwiftUI
import Foundation
import Alamofire
import KeychainSwift

class TopicsViewModel: ObservableObject {
    @Published var resultTopics: [TopicsModel] = []
    @Published var topicStatus: [TopicsStatusModel] = []
     
    // Método que coincide con la nueva firma utilizada en TopicsView
    func getTopics(userID: Int, contentID: Int) async {
        await getTopics(contentIDVM: contentID, userIDVM: userID)
    }

    func getTopics(contentIDVM: Int, userIDVM: Int) async {
        do {
            let topics: [TopicsModel] = try await APIClient.get(path: "getTopics/\(userIDVM)/\(contentIDVM)")
            DispatchQueue.main.async {
                self.resultTopics = topics
                
                print("Number of topics fetched: \(topics.count)")
                for topic in topics {
                    print("Topic: \(topic.title)")
                    print("Thumbnail URL: \(topic.thumbnail_url)")
                    
                    let processedURL = APIClient.getFullImageURL(topic.thumbnail_url)
                    print("Processed URL: \(processedURL)")
                    
                    if let url = URL(string: processedURL) {
                        print("Valid URL: \(url)")
                    } else {
                        print("Invalid URL created from: \(processedURL)")
                    }
                }
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
        let url = "https://phill-api.diloensenas.org/api/auth/UpdateDone"

        // Define el cuerpo de la petición
        let parameters: [String: Any] = [
            "user": user,
            "topic": topic,
            "done": done
        ]

        // ejecutamos con alamofire
        var headers: HTTPHeaders = []
        if let token = getToken() {
            headers.add(name: "Authorization", value: "Bearer \(token)")
        }
        
        AF.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { response in
            switch response.result {
            case .success:
                print("Message registered successfully!")
            case .failure(let error):
                print("Error registering message: \(error)")
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

        // Define el cuerpo de la petición
        let parameters: [String: Any] = [
            "user": user,
            "topic": topic,
            "done": true
        ]

        // ejecutamos con alamofire
        var headers: HTTPHeaders = []
        if let token = getToken() {
            headers.add(name: "Authorization", value: "Bearer \(token)")
        }
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { response in
            switch response.result {
            case .success:
                print("Message registered successfully!")
            case .failure(let error):
                print("Error registering message: \(error)")
            }
        }
    }
}
