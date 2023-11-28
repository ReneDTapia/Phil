import SwiftUI
import Foundation

class ContentsViewModel: ObservableObject{
    @Published var resultContents: [ContentsModel] = []
    
    

    func getContents(userIDVM: Int) async {
            
            do {
                let contents: [ContentsModel] = try await APIClient.get(path: "getContent/\(userIDVM)")
                DispatchQueue.main.async {
                    self.resultContents = contents
                }
            } catch {
                print("Error fetching contents: \(error)")
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
