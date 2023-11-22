import Foundation
import Alamofire

class PictureViewModel: ObservableObject {
    @Published var photos: [Picture] = []
    private var userID: Int?
    @Published var currentDate = Date()

    init() {
        self.userID = 1 // Asegúrate de configurar esto adecuadamente
        fetchPhotos(for: currentDate)
    }

    func fetchPhotos(for date: Date) {
        self.photos = []
        guard let userID = userID else {
            print("UserID no disponible")
            return
        }

        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MM"
        
        let yearString = yearFormatter.string(from: date)
        let monthString = monthFormatter.string(from: date)

        let urlString = "https://philbackend.onrender.com/api/auth/GetPicturesMonth/\(userID)/\(yearString)/\(monthString)"

        AF.request(urlString).response { response in
            switch response.result {
            case .success(let data):
                if let data = data, let string = String(data: data, encoding: .utf8) {
                    print("Respuesta en bruto: \(string)")
                    self.decodePictures(data: data)
                }
            case .failure(let error):
                print("Error al realizar la petición: \(error.localizedDescription)")
            }
        }
    }

    func nextMonth() {
        guard let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) else { return }
        currentDate = nextMonth
        fetchPhotos(for: currentDate)
    }

    func previousMonth() {
        guard let prevMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) else { return }
        currentDate = prevMonth
        fetchPhotos(for: currentDate)
    }
    private func decodePictures(data: Data) {
        let decoder = JSONDecoder()
        do {
            let pictures = try decoder.decode([Picture].self, from: data)
            DispatchQueue.main.async {
                self.photos = pictures
            }
        } catch {
            print("Error al decodificar: \(error)")
        }
    }
}
