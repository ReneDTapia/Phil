import SwiftUI
import Foundation

class SectionsViewModel: ObservableObject{
    @Published var resultSections: [SectionsModel] = []
     
    func getSections(topicIDVM: Int) async {
            do {
                let sections: [SectionsModel] = try await APIClient.get(path: "getSections/\(topicIDVM)")
                DispatchQueue.main.async {
                    self.resultSections = sections
                }
            } catch {
                print("Error al obtener las secciones: \(error)")
            }
    }
}
