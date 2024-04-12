//  GPTView.swift
//  Phil
//
//  Created by Jesús Daniel Martínez García on 19/10/23.
//

import SwiftUI
import SwiftOpenAI


struct GPTView: View {
    
    var conversationId: Int
    var userId : Int
    
    @StateObject var viewModel = GPTViewModel()
    @State var prompt : String = ""
    @State private var showMenu = false
    @StateObject var chatViewModel = ChatViewModel()
    @Environment(\.presentationMode) var presentationMode

    
    
    
    var body: some View {
        //Side bar
        GeometryReader{
            
            geometry in
            
            NavigationStack{
                
                ZStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        HStack{
                            Button(action: {
                                withAnimation {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }) {HStack{ 
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
                        
                        
                        ////
                        //seccionchatgpt(?)
                        
                        Spacer()
                        
                        VStack {
                            if chatViewModel.messages.isEmpty && viewModel.messages.isEmpty{
                                Text("Haz una pregunta para comenzar una conversación")
                                    .bold()
                                    .multilineTextAlignment(.center)
                            }
                            ConversationView(chatViewModel: chatViewModel)
                                .environmentObject(viewModel)
                                .padding(.horizontal, 12)
                                .frame(maxWidth: .infinity)
                            HStack{
                                
                                TextField("Chatea con Phil", text: $prompt, axis: .vertical)
                                    .padding(12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(25)
                                    .lineLimit(6)
                                Button {
                                    Task {
                                        
                                        await sendMessageWithUserContext()
                                        prompt = ""
                                        
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
                            
                        }.padding()
                        
                        
                        //AQUI TERMINA LA SECCION DE GPT
                        
                    }
                    
                    
                }.onAppear {
                    
                    viewModel.fetchUserForm(Users_id: userId)
                    chatViewModel.fetchMessages(conversationId: conversationId) //
                    
                    
                }
                
            }
        }
        .navigationBarBackButtonHidden(true)
        
    }
    
    
    
    private func sendMessageWithUserContext() async {
        let userContextMessage = "Contexto del usuario (Responde todo lo que te pregunte en base a esta información):\n" + viewModel.userForm.map { "Preguntas de salud mental del usuario: \($0.texto), el usuario se identifica con la pregunta con este porcentaje: \($0.Percentage)0%, guia al usuario con toda esta información según que tanto porcentaje se identificó con esa pregunta, entre más porcentaje más se siente identificado." }.joined(separator: "\n")
        await viewModel.send(message: prompt, userContext: userContextMessage, conversationId: conversationId, userId: userId)
       }
    
    private func scrollToLatestMessage(using scrollViewProxy: ScrollViewProxy) {
            if let lastMessage = chatViewModel.messages.last {
                withAnimation {
                    scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
    }
}



struct GPTView_Previews: PreviewProvider {
    static var previews: some View {
        // Creas una instancia de GPTViewModel
        let gptViewModel = GPTViewModel()
        // Creas una instancia de ChatViewModel si es necesario
        let chatViewModel = ChatViewModel()
        
        // Pasas las instancias al inicializador de GPTView
        MainView() // Si GPTView depende de un EnvironmentObject
    }
}
