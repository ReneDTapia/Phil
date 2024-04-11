import SwiftUI

struct ConversationView: View {
    @EnvironmentObject var gptViewModel: GPTViewModel
    @ObservedObject var chatViewModel: ChatViewModel

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack(spacing: 15) {
                    // Mostrar mensajes antiguos
                    ForEach(chatViewModel.messages) { message in
                        TextMessageView2(message: message)
                    }

                    // Mostrar TODOS LOS mensajes de esa conversación
                    ForEach(gptViewModel.messages) { message in
                        if !message.hidden {
                            TextMessageView(message: message)
                        }
                    }
                }
                .onChange(of: chatViewModel.messages.count) { _ in
                    if let lastMessageId = chatViewModel.messages.last?.id {
                        scrollView.scrollTo(lastMessageId, anchor: .bottom)
                    }
                }
                .onChange(of: gptViewModel.messages.count) { _ in
                    if let lastMessageId = gptViewModel.messages.last?.id {
                        scrollView.scrollTo(lastMessageId, anchor: .bottom)
                    }
                }
            }
        }
        .onAppear {
            gptViewModel.messages = []
            chatViewModel.messages = []
        }
    }
}
