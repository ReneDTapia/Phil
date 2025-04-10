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
    var threadId: String?
    
    @StateObject var viewModel = GPTViewModel()
    @State var prompt : String = ""
    @State var pregunta : String = ""
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
                            .gesture(
                                    DragGesture()
                                        .onEnded { value in
                                            if value.translation.width > 100 {  // Comprobar el arrastre hacia la derecha
                                                withAnimation {
                                                    presentationMode.wrappedValue.dismiss()  // Cerrar la vista
                                                }
                                            }
                                        }
                                )
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
                                
                                TextField("Chatea con Phil", text: $pregunta, axis: .vertical)
                                    .padding(12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(25)
                                    .lineLimit(6)
                                    .disabled(viewModel.isProcessing)
                                
                                if viewModel.isProcessing {
                                    ProgressView()
                                        .frame(width: 44, height: 44)
                                        .background(Color.gray.opacity(0.5))
                                        .cornerRadius(22)
                                } else {
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
                            
                        }.padding()
                        
                        
                        //AQUI TERMINA LA SECCION DE GPT
                        
                    } .gesture(
                        DragGesture()
                            .onEnded { value in
                                if value.translation.width > 100 {  // Comprobar deslizamiento hacia la izquierda
                                    withAnimation {
                                        presentationMode.wrappedValue.dismiss()  // Cerrar la vista
                                    }
                                }
                            }
                    )
                    
                    
                }.onAppear {
                    
                    // Imprimir información de depuración
                    print("GPTView apareció - Configurando conversación")
                    print("ID de conversación: \(conversationId)")
                    print("ID de usuario pasado como parámetro: \(userId)")
                    print("Thread ID pasado como parámetro: \(threadId ?? "No disponible")")
                    
                    // Verificar el ID de usuario almacenado en el token
                    let tokenUserId = TokenHelper.getUserID() ?? 0
                    print("ID de usuario en token: \(tokenUserId)")
                    
                    // Usar el userId del token si está disponible, de lo contrario usar el pasado como parámetro
                    let userIdToUse = tokenUserId != 0 ? tokenUserId : userId
                    print("Usando ID de usuario: \(userIdToUse)")
                    
                    // Obtener el formulario del usuario
                    viewModel.fetchUserForm(Users_id: userIdToUse)
                    
                    // Si tenemos threadId desde los parámetros, usarlo directamente
                    if let threadIdParam = threadId, !threadIdParam.isEmpty {
                        print("✅ Usando thread_id recibido como parámetro: \(threadIdParam)")
                        
                        // Guardar el thread_id en ambos view models
                        viewModel.currentThreadId = threadIdParam
                        chatViewModel.currentThreadId = threadIdParam
                        
                        // Cargar solo los mensajes sin intentar obtener el thread_id de nuevo
                        chatViewModel.fetchOnlyMessages(conversationId: conversationId)
                    } else {
                        // Si no tenemos el threadId desde los parámetros, intentar obtenerlo usando el método findThreadIdByAnyMeans
                        Task {
                            print("🔍 No se recibió un thread_id válido como parámetro. Buscando por otros medios...")
                            if let foundThreadId = await chatViewModel.findThreadIdByAnyMeans(conversationId: conversationId, userId: userIdToUse) {
                                print("✅ Thread ID encontrado: \(foundThreadId)")
                                viewModel.currentThreadId = foundThreadId
                                chatViewModel.currentThreadId = foundThreadId
                                
                                // Ya tenemos el threadId, ahora solo cargamos los mensajes
                                chatViewModel.fetchOnlyMessages(conversationId: conversationId)
                            } else {
                                print("❌ No se encontró ningún thread_id para la conversación. Creando uno nuevo...")
                                
                                // Si no se encontró el thread_id por ningún medio, crear uno nuevo
                                if let newThreadId = await chatViewModel.createOpenAIThread() {
                                    print("✅ Nuevo thread creado con ID: \(newThreadId)")
                                    viewModel.currentThreadId = newThreadId
                                    chatViewModel.currentThreadId = newThreadId
                                    
                                    // Actualizar la conversación con el nuevo thread_id
                                    let updateSuccess = await viewModel.updateConversationWithThreadId(
                                        conversationId: conversationId, 
                                        threadId: newThreadId
                                    )
                                    
                                    if updateSuccess {
                                        print("✅ Conversación actualizada con nuevo threadId")
                                        
                                        // Cargar los mensajes después de actualizar la conversación
                                        chatViewModel.fetchOnlyMessages(conversationId: conversationId)
                                    } else {
                                        print("❌ No se pudo actualizar la conversación, pero el thread se creó")
                                        chatViewModel.fetchOnlyMessages(conversationId: conversationId)
                                    }
                                } else {
                                    print("❌ No se pudo crear un nuevo thread. Continuando sin thread_id...")
                                    chatViewModel.fetchOnlyMessages(conversationId: conversationId)
                                }
                            }
                        }
                    }
                    
                    // Validar que la API key sea correcta
                    OpenAIAPIKey.logInfo()
                }
                
            }
        }
        .navigationBarBackButtonHidden(true)
        
    }
    
    
    
    private func sendMessageWithUserContext() async {
        let userContextMessage = "Contexto del usuario (Responde todo lo que te pregunte en base a esta información):\n" + viewModel.userForm.map { "Preguntas de salud mental del usuario: \($0.texto), el usuario se identifica con la pregunta con este porcentaje: \($0.Percentage)0%, guia al usuario con toda esta información según que tanto porcentaje se identificó con esa pregunta, entre más porcentaje más se siente identificado. No contestes cosas no relacionadas o fuera del contexto de asistente de psicólogo." }.joined(separator: "\n")
        
        // Imprimir información de depuración
        print("🔄 Enviando mensaje para conversationId: \(conversationId)")
        print("Thread ID actual en ChatViewModel: \(chatViewModel.currentThreadId ?? "No disponible")")
        print("Thread ID actual en GPTViewModel: \(viewModel.currentThreadId ?? "No disponible")")
        
        // IMPORTANTE: Asegurarnos que tenemos un thread_id válido antes de continuar
        if let threadId = chatViewModel.currentThreadId, !threadId.isEmpty {
            print("✅ Usando thread_id del ChatViewModel: \(threadId)")
            viewModel.currentThreadId = threadId
        } else if let threadId = viewModel.currentThreadId, !threadId.isEmpty {
            print("✅ Usando thread_id del GPTViewModel: \(threadId)")
            chatViewModel.currentThreadId = threadId
        } else {
            // Si no tenemos thread_id en ninguno de los ViewModels, intentamos buscarlo o crear uno nuevo
            print("⚠️ No hay thread_id disponible. Intentando encontrar o crear uno...")
            
            // 1. Primero, intentar buscar en las conversaciones localmente
            if let conversation = chatViewModel.conversations.first(where: { $0.id == conversationId }),
               let threadId = conversation.threadId, !threadId.isEmpty {
                print("✅ Thread ID encontrado en lista de conversaciones: \(threadId)")
                viewModel.currentThreadId = threadId
                chatViewModel.currentThreadId = threadId
            } else {
                // 2. Si no se encuentra localmente, buscamos remotamente usando findThreadIdByAnyMeans
                print("⚠️ No se encontró localmente. Buscando thread_id por todos los medios...")
                let foundThreadId = await chatViewModel.findThreadIdByAnyMeans(conversationId: conversationId, userId: userId)
                
                if let threadId = foundThreadId, !threadId.isEmpty {
                    print("✅ Thread ID encontrado remotamente: \(threadId)")
                    viewModel.currentThreadId = threadId
                    chatViewModel.currentThreadId = threadId
                } else {
                    // 3. Si aún no encontramos, creamos uno nuevo
                    print("⚠️ No se encontró ningún thread_id. Creando uno nuevo...")
                    if let newThreadId = await chatViewModel.createOpenAIThread() {
                        print("✅ Nuevo thread creado: \(newThreadId)")
                        viewModel.currentThreadId = newThreadId
                        chatViewModel.currentThreadId = newThreadId
                        
                        // Actualizar la conversación con el nuevo thread_id
                        let updateSuccess = await viewModel.updateConversationWithThreadId(
                            conversationId: conversationId,
                            threadId: newThreadId
                        )
                        
                        if updateSuccess {
                            print("✅ Conversación actualizada con el nuevo thread_id")
                        } else {
                            print("❌ No se pudo actualizar la conversación, pero se usará el thread_id creado")
                        }
                    } else {
                        print("❌ No se pudo crear un thread_id. Enviando sin thread_id...")
                    }
                }
            }
        }
        
        // Verificación final del thread_id antes de enviar el mensaje
        print("🔍 Thread ID final a utilizar: \(viewModel.currentThreadId ?? "No disponible")")
        
        // Enviar el mensaje usando el viewModel
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
