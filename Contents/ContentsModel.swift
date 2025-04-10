import Foundation

struct ContentsModel: Decodable{
    var id : Int
    var title: String
    var description: String
    var proporcion: Double?
    var thumbnail_url: String
    var topicCount: String?
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case proporcion
        case thumbnail_url
        case topicCount
    }
}
