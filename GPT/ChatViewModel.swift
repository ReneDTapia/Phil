import Foundation
import Combine
import Alamofire

class ChatViewModel: ObservableObject {
    
    @Published var conversations: [Conversation] = []
    @Published var messages: [Message] = []
    
    // Utiliza APIClient para obtener las conversaciones jajajaj de nada papus
    func fetchConversations(userId: Int) {
        APIClient.get(path: "getUserConversations/\(userId)") { [weak self] (result: Result<[Conversation], AFError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let conversations):
                    self?.conversations = conversations
                case .failure(let error):
                    print("Error fetching conversations: \(error.localizedDescription)")
                }
            }
        }
    }

    // Utiliza APIClient para obtener los mensajes siuuu:v
    func fetchMessages(conversationId: Int) {
        APIClient.get(path: "getConversation/\(conversationId)") { [weak self] (result: Result<[Message], AFError>) in
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
}
