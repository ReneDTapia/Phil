import SwiftUI
import Foundation

class ContentsViewModel: ObservableObject {
    @Published var resultContents: [ContentsModel] = []
    
    func getContents(userIDVM: Int) async {
        do {
            let contents: [ContentsModel] = try await APIClient.get(path: "getContent/\(userIDVM)")
            DispatchQueue.main.async {
                self.resultContents = contents
                
                // Debug information for image URLs
                print("Number of contents fetched: \(contents.count)")
                for content in contents {
                    print("Content: \(content.title)")
                    print("Thumbnail URL: \(content.thumbnail_url)")
                    
                    let processedURL = APIClient.getFullImageURL(content.thumbnail_url)
                    print("Processed URL: \(processedURL)")
                    
                    if let url = URL(string: processedURL) {
                        print("Valid URL: \(url)")
                    } else {
                        print("Invalid URL created from: \(processedURL)")
                    }
                }
            }
        } catch {
            print("Error fetching contents: \(error)")
        }
    }
}

// Commented-out old implementation
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
