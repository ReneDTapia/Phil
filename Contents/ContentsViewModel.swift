import SwiftUI
import Foundation

class ContentsViewModel: ObservableObject{
    @Published var resultContents: [ContentsModel] = []
    
    func getContents() async throws{
        guard let url = URL(string: "https://philbackend.onrender.com/api/auth/getContent") else{
            print("invalid url")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        
        let (data,response) = try await URLSession.shared.data(for: urlRequest)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else{
            print("error")
            return
        }
        
        let results = try JSONDecoder().decode([ContentsModel].self, from: data)
        
        DispatchQueue.main.async{
            self.resultContents = results
        }
    }
}
