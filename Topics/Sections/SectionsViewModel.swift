import SwiftUI
import Foundation

class SectionsViewModel: ObservableObject{
    @Published var resultSections: [SectionsModel] = []
     
    func getSections(topicIDVM : Int) async throws{
        guard let url = URL(string: "https://philbackend.onrender.com/api/auth/getSections/" + String(topicIDVM)) else{
            print("invalid url")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        
        let (data,response) = try await URLSession.shared.data(for: urlRequest)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else{
            print("error")
            return
        }
        
        let results = try JSONDecoder().decode([SectionsModel].self, from: data)
        
        
        DispatchQueue.main.async{
            self.resultSections = results
        }
    }
}
