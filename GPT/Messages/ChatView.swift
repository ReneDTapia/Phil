import SwiftUI
import SwiftOpenAI


//esta vista ya no se usa pues se integró todo en GPT VIEW.

struct ChatView: View {
    @StateObject var viewModel: ChatViewModel = ChatViewModel()
    @State private var newMessage: String = ""
    @State private var messageLoad = "Cargando..."
    
    var conversationId: Int
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(viewModel.messages) { message in
                                            TextMessageView2(message: message)}
                }.padding()
            }
            
          
        }
        .onAppear {
            task{
                do{
                    try await viewModel.fetchMessages(conversationId: conversationId)
                    if viewModel.messages.isEmpty{
                        messageLoad = "No hay datos"
                        
                    }
                }
                catch{
                    print("error")
                }
            }
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
