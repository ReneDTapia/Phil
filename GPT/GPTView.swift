import SwiftUI
import SwiftOpenAI

struct GPTView: View {
    var conversationId: Int
    var userId: Int

    @StateObject var viewModel = GPTViewModel()
    @State var prompt: String = ""
    @State var pregunta: String = ""
    @StateObject var chatViewModel = ChatViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading) {
            // Botón de regresar simple
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.indigo)
                        Text("Regresar")
                            .font(.caption)
                            .foregroundColor(.indigo)
                    }
                }
                .padding(.leading, 20)
                
                Spacer()
            }
            
            Text("Chatea con Phil")
                .font(.largeTitle)
                .bold()
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 10))
            
            Spacer()
            
            VStack {
                if chatViewModel.messages.isEmpty && viewModel.messages.isEmpty {
                    Text("Haz una pregunta para comenzar una conversación")
                        .bold()
                        .multilineTextAlignment(.center)
                }
                ConversationView(chatViewModel: chatViewModel)
                    .environmentObject(viewModel)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity)
                
                HStack {
                    TextField("Chatea con Phil", text: $pregunta, axis: .vertical)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(25)
                        .lineLimit(6)
                    
                    Button {
                        Task {
                            prompt = pregunta
                            pregunta = ""
                            await sendMessageWithUserContext()
                        }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .frame(width: 44, height: 44)
                            .background(Color.indigo)
                            .cornerRadius(22)
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 8)
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .background(Color.white)
        .onAppear {
            viewModel.fetchUserForm(Users_id: userId)
            chatViewModel.fetchMessages(conversationId: conversationId)
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 100 {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        )
    }
    
    private func sendMessageWithUserContext() async {
        let userContextMessage = "Contexto del usuario (Responde todo lo que te pregunte en base a esta información):\n" + viewModel.userForm.map { "Preguntas de salud mental del usuario: \($0.texto), el usuario se identifica con la pregunta con este porcentaje: \($0.Percentage)0%, guía al usuario con toda esta información según que tanto porcentaje se identificó con esa pregunta, entre más porcentaje más se siente identificado. No contestes cosas no relacionadas o fuera del contexto de asistente de psicólogo." }.joined(separator: "\n")
        await viewModel.send(message: prompt, userContext: userContextMessage, conversationId: conversationId, userId: userId)
    }
}

#Preview{
    MainView()
}
