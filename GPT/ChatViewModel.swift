import Foundation
import Combine
import Alamofire

class ChatViewModel: ObservableObject {
    
    @Published var conversations: [Conversation] = []
    @Published var messages: [Message] = []
    @Published var newConversationId: Int?
    
    // Utiliza APIClient para obtener las conversaciones jajajaj de nada papus
    func fetchConversations(userId: Int) async {
        do {
            let fetchedConversations: [Conversation] = try await APIClient.get(path: "getUserConversations/\(userId)")
            DispatchQueue.main.async { [weak self] in
                self?.conversations = fetchedConversations
            }
        } catch {
            print("Error fetching conversations: \(error.localizedDescription)")
        }
    }


    // Utiliza APIClient para obtener los mensajes siuuu:v
    func fetchMessages(conversationId: Int) {
        APIClient.getN(path: "getConversation/\(conversationId)") { [weak self] (result: Result<[Message], AFError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let messages):
                    self?.messages = messages
                case .failure(let error):
                    print("Error fetching messages: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func registerConversationWithAlamofire(name: String, userId: Int) async -> Int? {
            let parameters: Parameters = [
                "name": name,
                "userId": userId
            ]

            do {
                let data: Data? = try await APIClient.post(path: "addConversation", parameters: parameters)
                if let data = data {
                    let conversationResponse = try JSONDecoder().decode(ConversationResponse.self, from: data)
                    self.newConversationId = conversationResponse.conversationId
                    return conversationResponse.conversationId
                } else {
                    print("No data received")
                    return nil
                }
            } catch {
                print("Error adding conversation: \(error.localizedDescription)")
                return nil
            }
        }
    
    func deleteConversation(conversationId: Int) async -> Bool {
        do {
            try await APIClient.delete(path: "deleteConversation/\(conversationId)")
            DispatchQueue.main.async { [weak self] in
                self?.conversations.removeAll { $0.id == conversationId }
            }
            return true
        } catch {
            print("Error deleting conversation: \(error.localizedDescription)")
            return false
        }
    }

    
    func updateConversationName(conversationId: Int, newName: String) async -> Bool {
            let parameters: Parameters = ["name": newName]

            do {
                let response: UpdateConversationResponse = try await APIClient.put(path: "updateConversationName/\(conversationId)", parameters: parameters)
                print(response.success)
                return true
            } catch {
                print("Error updating conversation name: \(error.localizedDescription)")
                return false
            }
        }

}
