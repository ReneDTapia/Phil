import Foundation

struct ContentsModel: Decodable{
    var id : Int
    var title: String
    var description: String
    var proporcion: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case proporcion
    }
}
