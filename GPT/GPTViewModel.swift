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
    func send(message: String, isHidden: Bool = false, userContext: String, conversationId : Int) async {
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
            registerMessageWithAlamofire(message: message, sentByUser: true, userId: 1, conversationId: conversationId)
        
        do {
            let stream = try await openAI.createChatCompletionsStream(
                model: .gpt3_5(.turbo),
                messages: messages,
                optionalParameters: optionalParameters
            )
            
            for try await response in stream {
                print(response)
                await onReceive(newMessage: response, conversationId:  conversationId)
            }
        } catch {
            print("Error: \(error)")
        }
    }

    
    
    
    @MainActor
    private func onReceive(newMessage: ChatCompletionsStreamDataModel, conversationId : Int){
            let lastMessage = newMessage.choices[0]
            
            guard lastMessage.finishReason == nil else{
                print("finished sendin el message pa lol")
                registerMessageWithAlamofire(message: currentMessage.text, sentByUser: false, userId: 1, conversationId: conversationId)
                return
            }
            
            guard let content = lastMessage.delta?.content else{
                //print("message with no cont")
                return
            }
            
            currentMessage.text = currentMessage.text + content
            messages[messages.count - 1].text = currentMessage.text
            
            
        }


    
    // Utiliza APIClient para obtener el formulario del usuario
        func fetchUserForm(Users_id: Int) {
            APIClient.getN(path: "getUserForm/\(Users_id)") { [weak self] (result: Result<[UserForm], AFError>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let forms):
                        self?.userForm = forms
                        print("UserForm: \(forms)")
                    case .failure(let error):
                        print("Error fetching user form: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        // Utiliza APIClient para registrar un mensaje con Alamofire
        func registerMessageWithAlamofire(message: String, sentByUser: Bool, userId: Int, conversationId: Int) {
            let parameters: Parameters = [
                "text": message,
                "sentByUser": sentByUser,
                "user": userId,
                "conversationId": conversationId
            ]
            
            APIClient.postN(path: "addMessage", parameters: parameters) { response in
                switch response.result {
                case .success:
                    if let statusCode = response.response?.statusCode, statusCode == 200 {
                        print("Message registered successfully!")
                    } else {
                        print("Received unexpected status code: \(response.response?.statusCode ?? 0)")
                    }
                case .failure(let error):
                    print("Error registering message: \(error.localizedDescription)")
                }
            }
        }

}
