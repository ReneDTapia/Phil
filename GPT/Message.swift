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
    let threadId: String? // ADD: Thread ID for OpenAI

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user"
        case text
        case sentByUser
        case conversationId
        case sendAt
        case threadId // ADD: Coding key for threadId
    }
}

struct Conversation: Identifiable, Decodable {
    let id: Int
    let name : String
    let lastMessageAt: String?
    
    
    enum CodingKeys: String, CodingKey {
        case id = "conversationId"
        case name
        case lastMessageAt
        
    }
}

struct ConversationResponse: Codable {
    let conversationId: Int
}

struct UpdateConversationResponse: Decodable {
    let success: String
}
