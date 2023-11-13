import SwiftUI
import Foundation
import Alamofire

class TopicsViewModel: ObservableObject{
    @Published var resultTopics: [TopicsModel] = []
    @Published var topicStatus: [TopicsStatusModel] = []
     

    func getTopics(contentIDVM : Int, userIDVM : Int) async throws{
        guard let url = URL(string: "https://philbackend.onrender.com/api/auth/getTopics/\(userIDVM)/\(contentIDVM)") else{

            print("invalid url")
            return
        }
        print(url)
        let urlRequest = URLRequest(url: url)
        
        let (data,response) = try await URLSession.shared.data(for: urlRequest)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else{
            print("error")
            return
        }
        
        let results = try JSONDecoder().decode([TopicsModel].self, from: data)
        
        print(results)
        DispatchQueue.main.async{
            self.resultTopics = results
        }
    }
    
    func getTopicsStatus(contentIDVM : Int, userIDVM : Int) async throws{
        guard let url = URL(string: "https://philbackend.onrender.com/api/auth/getUserResult/\(userIDVM)/\(contentIDVM)") else{

            print("invalid url")
            return
        }
        print(url)
        let urlRequest = URLRequest(url: url)
        
        let (data,response) = try await URLSession.shared.data(for: urlRequest)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else{
            print("error")
            return
        }
        
        let results = try JSONDecoder().decode([TopicsStatusModel].self, from: data)
        
        print(results)
        DispatchQueue.main.async{
            self.topicStatus = results
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
