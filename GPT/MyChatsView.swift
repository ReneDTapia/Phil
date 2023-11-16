import SwiftUI

struct MyChatsView: View {
    @StateObject var viewModel = ChatViewModel()
    @StateObject var GPTviewModel = GPTViewModel()

    @State private var isEditing = false
    @State private var editingConversationId: Int? = nil
    @State private var updatedConversationName: String = ""
    @State private var newConversationName: String = ""
    @State private var isLoading = true
    @State private var messageLoad = "Cargando..."
    @State private var showingAddConversation = false

    var userId: Int

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Color.black.ignoresSafeArea(.all)
                    VStack(alignment: .leading) {
                        Text("Chatea con Phil")
                            .font(.largeTitle)
                            .bold()
                            .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 10))
                            .foregroundColor(.white)

                        // Botón para mostrar el campo de texto de nueva conversación
                        HStack {
                            Spacer()
                            Button(action: {
                                showingAddConversation.toggle()
                            }) {
                                Image(systemName: "plus")
                                    .padding()
                                    .foregroundColor(.white)
                            }
                        }

                        // Campo de texto que aparece solo cuando showingAddConversation es true
                        if showingAddConversation {
                            TextField("Nombre de la conversación:", text: $newConversationName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                            Button("Agregar") {
                                Task {
                                    let success = await viewModel.registerConversationWithAlamofire(name: newConversationName, userId: userId)
                                    
                                        
                                    if (success != nil) {
                                        newConversationName = ""
                                        showingAddConversation = false
                                        await viewModel.fetchConversations(userId: userId)
                                        isLoading = viewModel.conversations.isEmpty
                                    if viewModel.conversations.isEmpty {
                                        messageLoad = "No hay datos"
                                    }
                                    }
                                }
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }

                        Spacer()

                        if isLoading {
                            ProgressView(messageLoad)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .foregroundColor(Color.white)
                                .frame(width: geometry.size.width, height: geometry.size.height - 100)
                                .scaleEffect(1.5)
                        } else {
                            List {
                                ForEach(viewModel.conversations, id: \.id) { conversation in
                                    NavigationLink(destination: GPTView(conversationId: conversation.id, userId: userId)) {
                                        VStack(alignment: .leading) {
                                            if isEditing && editingConversationId == conversation.id {
                                                TextField("Nuevo nombre", text: Binding(
                                                    get: { updatedConversationName },
                                                    set: { updatedConversationName = $0 }
                                                ))
                                                .foregroundColor(Color.white)
                                            } else {
                                                Text("\(conversation.name)")
                                                    .foregroundColor(Color.white)
                                            }

                                            Text("Último mensaje: \(conversation.lastMessageAt ?? "No hay mensajes")")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            Task {
                                                let success = await viewModel.deleteConversation(conversationId: conversation.id)
                                                
                                                
                                                if success {
                                                        await viewModel.fetchConversations(userId: userId)
                                                        isLoading = viewModel.conversations.isEmpty
                                                        if viewModel.conversations.isEmpty {
                                                            messageLoad = "No hay datos"
                                                        }
                                                    // Actualizar lista de conversaciones
                                                }
                                            }
                                        } label: {
                                            Label("Eliminar", systemImage: "trash")
                                        }
                                        Button {
                                            if isEditing && editingConversationId == conversation.id {
                                                // Guardar cambios
                                                Task {
                                                    let success = await viewModel.updateConversationName(conversationId: conversation.id, newName: updatedConversationName)
                                                    if success {
                                                        print("Nombre de la conversación actualizado")
                                                        await viewModel.fetchConversations(userId: userId) // Recargar conversaciones
                                                        await viewModel.fetchConversations(userId: userId)
                                                        isLoading = viewModel.conversations.isEmpty
                                                    if viewModel.conversations.isEmpty {
                                                        messageLoad = "No hay datos"
                                                    }
                                                    }
                                                    editingConversationId = nil
                                                    isEditing = false
                                                }
                                            } else if isEditing && editingConversationId != nil {
                                                // Cancelar edición
                                                editingConversationId = nil
                                                isEditing = false
                                            } else {
                                                // Iniciar edición
                                                updatedConversationName = conversation.name
                                                editingConversationId = conversation.id
                                                isEditing = true
                                            }
                                        } label: {
                                            Label(isEditing && editingConversationId != nil && editingConversationId == conversation.id ? "Guardar" : "Editar", systemImage: "pencil")
                                        }
                                    }
                                    .listRowBackground(Color.black)
                                }
                            }
                            .listStyle(PlainListStyle())
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchConversations(userId: userId)
                    isLoading = viewModel.conversations.isEmpty
                    if viewModel.conversations.isEmpty {
                        messageLoad = "No hay datos"
                    }
                }
            }
        }
    }
}

struct MyChatsView_Previews: PreviewProvider {
    static var previews: some View {
        MyChatsView(userId: 1)
    }
}
