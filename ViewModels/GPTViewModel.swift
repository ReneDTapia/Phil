//
//  GPTViewModel.swift
//  Phil
//
//  Created by Jesús Daniel Martínez García on 19/10/23.
//

import SwiftUI
import SwiftOpenAI

final class GPTViewModel : ObservableObject {
    
    
    @Published var messages : [MessageChatGPT] = [
        .init(text: "Hola! soy Phil y te puedo ayudar a sentirte mejor en tu salud mental y tus emociones:V", role: .system)
    ]
    
    @Published var currentMessage : MessageChatGPT = .init(text: "", role: .assistant)
    
    var openAI = SwiftOpenAI(apiKey: "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")
    
    func send(message: String) async {
        
        let optionalParameters = ChatCompletionsOptionalParameters(temperature: 0.7, stream: true, maxTokens: 300)
        
        
        await MainActor.run{
            let myMessage = MessageChatGPT(text: message, role: .user)
            
            self.messages.append(myMessage)
            
            self.currentMessage = MessageChatGPT(text: "", role: .assistant)
            self.messages.append(self.currentMessage)
        }

        
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
            return
        }
        
        guard let content = lastMessage.delta?.content else{
            print("message with no cont")
            return
        }
        
        currentMessage.text = currentMessage.text + content
        messages[messages.count - 1].text = currentMessage.text
    }
    
}
