//
//  ConversationView.swift
//  Phil
//
//  Created by Jesús Daniel Martínez García on 20/10/23.
//

import SwiftUI

struct ConversationView: View {
    @EnvironmentObject var gptViewModel: GPTViewModel
    @ObservedObject var chatViewModel: ChatViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                // Mostrar mensajes antiguos
                ForEach(chatViewModel.messages) { message in
                    TextMessageView2(message: message)
                }
                
                // Mostrar TODOS LOS mensajes de esa conversación
                ForEach(gptViewModel.messages) {message in  if !message.hidden {
                    TextMessageView(message: message)
                }
                }
            }
        }
    }
}
