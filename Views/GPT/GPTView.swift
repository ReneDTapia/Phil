//
//  GPTView.swift
//  Phil
//
//  Created by Jesús Daniel Martínez García on 19/10/23.
//

import SwiftUI
import SwiftOpenAI


struct GPTView: View {
    
    var conversationId: Int
    
    var viewModel = GPTViewModel()
    @State var prompt : String = "Que onda, cómo te llamas puedes ayudarme a identificar mis emociones?"
    
    @State private var showMenu = false
    
    @StateObject var chatViewModel: ChatViewModel = ChatViewModel()

    
    
    
    var body: some View {
        //Side bar
        GeometryReader{
            
            geometry in
            
            ZStack(alignment: .leading) {
                Color.black
                    .ignoresSafeArea(.all)
                VStack(alignment: .leading) {
                    HStack {
                        // Botón del menú
                        Button(action: {
                            withAnimation {
                                self.showMenu.toggle()
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Circle()
                            .fill(Color.white)
                            .frame(width: 50, height: 50)
                    }
                    .padding(EdgeInsets(top: 30, leading: 20, bottom: 0, trailing: 20))
                    Text("Chatea con Phil")
                        .font(.largeTitle)
                        .bold()
                        .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 10))
                        .foregroundColor(.white)
                    
                    
                    ////
                    //seccionchatgpt(?)
                    
                    Spacer()
                    
                    VStack {
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
                                    .foregroundColor(Color.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.purple)
                                    .cornerRadius(22)
                            }
                            .padding(.leading, 8)
                        }
                        
                    }.padding()
                    
                    
                    //AQUI TERMINA LA SECCION DE GPT
                    
                }
                
                
                if showMenu{
                    ZStack{
                        Color(.black)
                    }
                    .opacity(0.5)
                    .onTapGesture {
                        withAnimation{
                            showMenu = false
                        }
                        
                    }
                }
                
                HStack{
                    Menu(showMenu: $showMenu)
                        .offset(x:showMenu ? 0 : UIScreen.main.bounds.width * -1)
                        .frame(width: 300)
                    
                }
                
            }.onAppear {
                viewModel.fetchUserForm(Users_id: 1)
                chatViewModel.fetchMessages(conversationId: conversationId) //
            }

        }
    }
    
    
    
    private func sendMessageWithUserContext() async {
        let userContextMessage = "Contexto del usuario (Responde todo lo que te pregunte en base a esta información):\n" + viewModel.userForm.map { "Texto: \($0.texto), Checked: \($0.checked)" }.joined(separator: "\n")
           await viewModel.send(message: prompt, userContext: userContextMessage)
       }
}




