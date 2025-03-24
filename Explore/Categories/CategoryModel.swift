//
//  CategoryModel.swift
//  Phil
//
//  Created by Dario on 22/03/25.
//

import Foundation

struct CategoryModel: Decodable, Identifiable {
    var id: Int
    var name: String
    var emoji: String?
    var color: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case emoji
        case color
    }
}
