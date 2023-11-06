import Foundation

struct TopicsModel: Decodable, Identifiable{
    var id : Int
    var title: String
    var description: String
}
