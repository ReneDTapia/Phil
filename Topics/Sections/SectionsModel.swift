import Foundation

struct SectionsModel: Decodable, Identifiable {
    var id: Int
    var text: String?
    var video: String?
    var image: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case video
        case image
    }
}
