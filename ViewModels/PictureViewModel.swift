//
//  PicturesViewModel.swift
//  Phil
//
//  Created by Jesús Daniel Martínez García on 18/10/23.
//

import Foundation

class PicturesViewModel: ObservableObject {
    
    @Published var pictures: [Picture] = []
    
    func fetchPictures(user: Int, date: String) {
        guard let url = URL(string: "http://localhost:5005/api/auth/GetPictures/\(user)/\(date)") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }

            if let data = data {
                do {
                    let fetchedPictures = try JSONDecoder().decode([Picture].self, from: data)
                    DispatchQueue.main.async {
                        self.pictures = fetchedPictures
                        print("Pictures: \(fetchedPictures)")
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }
    
    func clearPictures() {
            pictures = []
    }
    
    
}
