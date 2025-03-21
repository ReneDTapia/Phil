import Foundation

struct TopicsModel: Decodable, Identifiable {
    var user_topic_id : Int?
    var done : Bool?
    var user : Int?
    var topic : Int
    var title: String
    var description: String
    var content : Int
    var thumbnail_url: String = ""
    
    // Propiedad id para conformar al protocolo Identifiable
    var id: Int {
        return user_topic_id ?? topic
    }
    
    enum CodingKeys: String, CodingKey {
        case user_topic_id
        case topic
        case done
        case user
        case title
        case description
        case content
        case thumbnail_url
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        user_topic_id = try container.decodeIfPresent(Int.self, forKey: .user_topic_id)
        done = try container.decodeIfPresent(Bool.self, forKey: .done)
        user = try container.decodeIfPresent(Int.self, forKey: .user)
        topic = try container.decode(Int.self, forKey: .topic)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        content = try container.decode(Int.self, forKey: .content)
        
        thumbnail_url = try container.decodeIfPresent(String.self, forKey: .thumbnail_url) ?? ""
    }
    
    init(user_topic_id: Int? = nil, done: Bool? = nil, user: Int? = nil, topic: Int, title: String, description: String, content: Int, thumbnail_url: String = "") {
        self.user_topic_id = user_topic_id
        self.done = done
        self.user = user
        self.topic = topic
        self.title = title
        self.description = description
        self.content = content
        self.thumbnail_url = thumbnail_url
    }
}



struct TopicsStatusModel: Decodable{
    var userresult: Int
    
    enum CodingKeys: String, CodingKey {
        case userresult
    }
}
