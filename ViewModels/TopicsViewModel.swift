import SwiftUI
import Foundation

class TopicsViewModel: ObservableObject{
    @Published var resultTopics: [TopicsModel] = []
     
    func getTopics(contentIDVM : Int) async throws{
        guard let url = URL(string: "\(API.baseURL)getTopics/" + String(contentIDVM)) else{
            print("invalid url")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        
        let (data,response) = try await URLSession.shared.data(for: urlRequest)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else{
            print("error")
            return
        }
        
        let results = try JSONDecoder().decode([TopicsModel].self, from: data)
        
        
        DispatchQueue.main.async{
            self.resultTopics = results
        }
    }
}
