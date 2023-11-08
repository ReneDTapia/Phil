import Foundation

struct TopicsModel: Decodable{
    var user_topic_id : Int?
    var done : Bool?
    var user : Int?
    var topic : Int
    var title: String
    var description: String
    var content : Int
    
    enum CodingKeys: String, CodingKey {
        case topic
        case done
        case user
        case title
        case description
        case content
    }
}

