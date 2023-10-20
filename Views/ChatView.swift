import SwiftUI
import SwiftOpenAI

struct ChatView: View {
    @StateObject var viewModel: ChatViewModel = ChatViewModel()
    @State private var newMessage: String = ""

    var conversationId: Int
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(viewModel.messages) { message in
                        if message.sentByUser {
                            SentMessageView(message: message)
                        } else {
                            ReceivedMessageView(message: message)
                        }
                    }
                }.padding()
            }
            
            HStack {
                TextField("Chatea con Phil...", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .cornerRadius(10)
                    .frame(maxHeight: 20)
                    .background(
                        RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.black, lineWidth: 1)
                                )
                
                Button(action: {
                    //viewModel.sendMessage(newMessage)
                    //newMessage = ""
                }) {
                    Image(systemName: "paperplane.fill")
                        .frame(width: 40, height: 40)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.fetchMessages(conversationId: conversationId) 
        }
    }
}

struct RoundTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1)) //
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ChatViewModel()
        return ChatView(viewModel: viewModel, conversationId: 1) // Aquí puedes cambiar el ID según sea necesario
    }
}

