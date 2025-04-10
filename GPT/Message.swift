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
    let name : String
    let lastMessageAt: String?
    let threadId: String?
    
    
    enum CodingKeys: String, CodingKey {
        case id = "conversationId"
        case name
        case lastMessageAt
        case threadId = "thread_id"
    }
}

struct ConversationResponse: Codable {
    let conversationId: Int?
    let threadId: String?
    let id: Int?  // Para cuando la API devuelve 'id' en lugar de 'conversationId'
    
    enum CodingKeys: String, CodingKey {
        case conversationId
        case threadId = "thread_id"
        case id
    }
    
    // Implementar un inicializador personalizado para manejar diferentes formatos
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Intentar decodificar conversationId, si no existe, intentamos con id
        if let conversationId = try? container.decode(Int.self, forKey: .conversationId) {
            self.conversationId = conversationId
            self.id = nil
        } else {
            self.id = try? container.decode(Int.self, forKey: .id)
            self.conversationId = self.id  // Usar id como conversationId si conversationId no existe
        }
        
        self.threadId = try? container.decode(String.self, forKey: .threadId)
    }
}

struct UpdateConversationResponse: Decodable {
    let success: String
}

// Estructura para endpoint alternativo de detalles de conversación
struct ConversationDetails: Decodable {
    let id: Int
    let name: String
    let thread_id: String?
    let user_id: Int?
    let created_at: String?
    let updated_at: String?
}

// Estructura para mensajes con información detallada
struct MessageWithDetails: Decodable {
    let id: Int
    let text: String
    let sent_by_user: Bool
    let user_id: Int
    let conversation_id: Int
    let thread_id: String?
    let created_at: String
}

// Modelo que combina una conversación con sus mensajes
struct ConversationWithMessages: Codable, Identifiable {
    let id: Int
    let name: String
    let userId: Int
    let createdAt: String
    let updatedAt: String
    let thread_id: String?
    let messages: [Message]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case userId = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case thread_id
        case messages
    }
}
