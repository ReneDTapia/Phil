//
//  GPTViewModel.swift
//  Phil
//
//  Created by Jesús Daniel Martínez García on 19/10/23.
//

import SwiftUI
import SwiftOpenAI
import Alamofire

final class GPTViewModel : ObservableObject {
    
    
    @Published var userForm : [UserForm] = []
    
    @Published var messages : [MessageChatGPT] = [
        .init(text: "Actúa como un psicologo llamado Phil y en todos mis mensajes ten en cuenta la siguiente informacion que te mandaré como contexto y si te pregunto algo con relación a lo siguiente ayudame a entenderlo como psicólogo" , role: .system, hidden: true)
    ]
    
    @Published var currentMessage : MessageChatGPT = .init(text: "", role: .assistant)
    
    var openAI = SwiftOpenAI(apiKey: "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")
    
    
    
    ///Funcion SEND
    ///
    func send(message: String, isHidden: Bool = false, userContext: String) async {
        let optionalParameters = ChatCompletionsOptionalParameters(temperature: 0.7, stream: true, maxTokens: 770)
        
        await MainActor.run {
            let userMessage = MessageChatGPT(text: message, role: .user, hidden: isHidden)
            let contextMessage = MessageChatGPT(text: userContext, role: .user, hidden: true)
            self.messages.append(contextMessage)
            self.messages.append(userMessage)
            
            self.currentMessage = MessageChatGPT(text: "", role: .assistant)
            self.messages.append(self.currentMessage)
        }
        // Registra el mensaje del usuario en la base de datos
            registerMessageWithAlamofire(message: message, sentByUser: true, userId: 1, conversationId: 2)
        
        do {
            let stream = try await openAI.createChatCompletionsStream(
                model: .gpt3_5(.turbo),
                messages: messages,
                optionalParameters: optionalParameters
            )
            
            for try await response in stream {
                print(response)
                await onReceive(newMessage: response)
            }
        } catch {
            print("Error: \(error)")
        }
    }

    
    
    
    @MainActor
        private func onReceive(newMessage: ChatCompletionsStreamDataModel){
            let lastMessage = newMessage.choices[0]
            
            guard lastMessage.finishReason == nil else{
                print("finished sendin el message pa lol")
                registerMessageWithAlamofire(message: currentMessage.text, sentByUser: false, userId: 1, conversationId: 2)
                return
            }
            
            guard let content = lastMessage.delta?.content else{
                //print("message with no cont")
                return
            }
            
            currentMessage.text = currentMessage.text + content
            messages[messages.count - 1].text = currentMessage.text
            
            
        }



    
    
    //FUNCION PARA OBTENER CONTEXTO DEL USUARIO:V
    func fetchUserForm(Users_id: Int)  {
        guard let url = URL(string: "https://philbackend.onrender.com/api/auth/getUserForm/\(Users_id)") else {
           // print("Invalida tu pinki URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching la data mike: \(error.localizedDescription)")
                return
            }

            if let data = data {
                do {
                    let messages = try JSONDecoder().decode([UserForm].self, from: data)
                    
                  //print("aqui estan las respuestas del usuario pibe", messages, "aquitermina las respuestas del usuario pibe")
                    
                    DispatchQueue.main.async {
                        self.userForm = messages
                        //print("UserForm: \(messages)")  //lol
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }
    
    
    
    //Función para registrar todos los mensajes en la base de datos! con alamofire papu:V
    
    func registerMessageWithAlamofire(message: String, sentByUser: Bool, userId: Int, conversationId: Int) {
        
        let url = "https://philbackend.onrender.com/api/auth/addMessage"

        // Define el cuerpo de la petición
        let parameters: [String: Any] = [
            "text": message,
            "sentByUser": sentByUser,
            "user": userId,
            "conversationId": conversationId
        ]

        // ejecutamos con alamofire
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { response in
            switch response.result {
            case .success:
                print("Message registered successfully!")
            case .failure(let error):
                print("Error registering message: \(error)")
            }
        }
    }

    
}
