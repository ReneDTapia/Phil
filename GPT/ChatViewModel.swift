import Foundation
import Combine

class ChatViewModel: ObservableObject {
    
    //ESTE ES PA VER TODAS LAS CONVERS QUE TIENE UN DETERMINADO USUARIO
    @Published var conversations: [Conversation] = []

    //ESTE ES PA VER TODOS LOS MENSAJES DE UNA DETERMINADA CONVER
    @Published var messages: [Message] = []
    
    //FUNCION PA VER LAS CONVERS
    func fetchConversations(userId: Int) {
        guard let url = URL(string: "https://philbackend.onrender.com/api/auth/getUserConversations/\(userId)") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }

            if let data = data {
                do {
                    let conversations = try JSONDecoder().decode([Conversation].self, from: data)
                    DispatchQueue.main.async {
                        self.conversations = conversations
                        print("Conversations: \(conversations)")
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }

    //FUNCION PA VER LOS MENSAJES DE LA CONVER LOL XD PAPU :V
    func fetchMessages(conversationId: Int) {
        guard let url = URL(string: "https://philbackend.onrender.com/api/auth/getConversation/\(conversationId)") else {
            print("Invalida tu pinki URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching la data mike: \(error.localizedDescription)")
                return
            }

            if let data = data {
                do {
                    let messages = try JSONDecoder().decode([Message].self, from: data)
                    
                    print("aqui estan los mensajes pibe", messages, "aqui terminan los mensajes pibe")
                    
                    DispatchQueue.main.async {
                        self.messages = messages
                        print("Messages: \(messages)")  //lol
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }
    
    
}

