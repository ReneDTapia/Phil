// Obtener una conversación completa con sus mensajes
static func getFullConversation(_ conversationId: Int) async throws -> ConversationWithMessages {
    guard let url = URL(string: "\(baseURL)/api/conversation/full/\(conversationId)") else {
        throw APIError.invalidURL
    }
    
    return try await fetchData(from: url, auth: true)
} 