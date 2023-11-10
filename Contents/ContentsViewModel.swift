import SwiftUI
import Foundation

class ContentsViewModel: ObservableObject{
    @Published var resultContents: [ContentsModel] = []
    
    

    func getContents(userIDVM: Int) async throws{
        guard let url = URL(string: "https://philbackend.onrender.com/api/auth/getContent/\(userIDVM)") else{

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


//Utilizando el API CLIENT.

//import SwiftUI
//import Foundation
//import Alamofire

//class ContentsViewModel: ObservableObject {
    //@Published var resultContents: [ContentsModel] = []
    
    //func getContents() {
        //APIClient.get(path: "getContent") { [weak self] (result: Result<[ContentsModel], AFError>) in
            //DispatchQueue.main.async {
                //switch result {
                //case .success(let contents):
                    //self?.resultContents = contents
                //case .failure(let error):
                    //print("Error fetching contents: \(error.localizedDescription)")
                //}
            //}
        //}
    //}
//}
