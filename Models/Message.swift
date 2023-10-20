//
//  Message.swift
//  Phil
//
//  Created by Jesús Daniel Martínez García on 18/10/23.
//

//TODOS LOS MODELOS RELACIONADOS AL CHATBOT CON PHIL SIUUUUUUUUUUUUUUUUUU


struct Message: Identifiable, Encodable, Decodable {
    let id: Int
    let userId: Int
    let text: String
    let sentByUser: Bool
    let conversationId: Int
    let sendAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user" // 
        case text
        case sentByUser
        case conversationId
        case sendAt
    }
}

struct Conversation: Identifiable, Decodable {
    let id: Int
    let lastMessageAt: String
    
    
    enum CodingKeys: String, CodingKey {
        case id = "conversationId"
        case lastMessageAt
    }
}

