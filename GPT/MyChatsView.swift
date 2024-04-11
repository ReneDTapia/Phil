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
    
    @State private var showModal = false

    var userId: Int

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        headerView
                        addButton
                        Spacer()
                        if isLoading{
                            Spacer()
                            if messageLoad == "Cargando..." {
                                ProgressView(messageLoad)
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .frame(width: geometry.size.width)
                                    .scaleEffect(1.5)
                                    .padding(.top,-100)
                            Spacer()
                            Spacer()
                            } else {
                                Spacer()
                                // Devuelve algo como un Text vacío o un Spacer
                                Text(messageLoad)
                                    .frame(width: geometry.size.width)
                                    .scaleEffect(1.5)
                                    .foregroundColor(.gray)
                                    .padding(.top,-100)
                                Spacer()
                                Spacer()
                                 
                            }
                            
                            
                        } else {
                            conversationsList
                        }
                    }
                }
            }
            .onAppear {
                loadConversations()
            }
        }
    }

    private var headerView: some View {
        Text("Chats con Mr Phil")
            .font(.largeTitle)
            .bold()
            .padding()
    }

    private var addButton: some View {
        HStack {
            Spacer()
            Button(action: { self.showModal = true
            }) {
                Image(systemName: "plus")
                    .padding()
                    .foregroundColor(.indigo)
            }
            .sheet(isPresented: $showModal) {
                ModalView(newConversationName: $newConversationName, addNewConversation: addNewConversation)
                    .presentationDetents([.fraction(0.3)])
            }

        }
    }

    private var newConversationField: some View {
        Group {
            if showingAddConversation {
                TextField("Nombre de la conversación:", text: $newConversationName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button("Agregar") { addNewConversation() }
                    .buttonStyle(BorderlessButtonStyle())
                    .foregroundColor(.indigo)
                    .padding(.horizontal)
            }
        }
    }

    struct ModalView: View {
        @Environment(\.presentationMode) var presentationMode
        @Binding var newConversationName: String
        var addNewConversation: () -> Void
        
        var body: some View {
            VStack {
                HStack{
                    Text("Nueva conversación")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    Spacer()
                }
                TextField("Nombre de la conversación", text: $newConversationName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                HStack{
                    Button("Agregar") {
                        addNewConversation()
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .foregroundColor(.indigo)
                    .padding(.horizontal)
                    Spacer()
                }
            }
            .padding()
        }
    }

    
    private func addNewConversation() {
        Task {
            let success = await viewModel.registerConversationWithAlamofire(name: newConversationName, userId: userId)
            if success != nil {
                newConversationName = ""
                showingAddConversation = false
                loadConversations()
            }
        }
    }

    private func loadConversations() {
        Task {
            await viewModel.fetchConversations(userId: userId)
            isLoading = viewModel.conversations.isEmpty
            messageLoad = viewModel.conversations.isEmpty ? "Inicia una nueva conversación" : "Cargando..."
        }
    }

    private func loadingView() -> some View {
        if messageLoad == "Cargando..." {
            return ProgressView(messageLoad)
                .progressViewStyle(CircularProgressViewStyle())
                
                .scaleEffect(1.5)
        } else {
            // Devuelve algo como un Text vacío o un Spacer
            return Text(messageLoad)
                .scaleEffect(1.5)
                .foregroundColor(.gray)
            
        }
    }

    
    private var conversationsList: some View {
        List {
            ForEach(viewModel.conversations, id: \.id) { conversation in
                conversationLink(for: conversation)
            }
        }
        .listStyle(PlainListStyle())
    }

    private func conversationLink(for conversation: Conversation) -> some View {
        NavigationLink(destination: GPTView(conversationId: conversation.id, userId: userId)) {
            VStack(alignment: .leading) {
                conversationNameView(conversation)
                Text("Último mensaje: \(conversation.lastMessageAt ?? "No hay mensajes")")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .swipeActions {
            deleteButton(for: conversation)
            editButton(for: conversation)
        }
    }

    private func conversationNameView(_ conversation: Conversation) -> some View {
        Group {
            if isEditing && editingConversationId == conversation.id {
                TextField("Nuevo nombre", text: $updatedConversationName)
            } else {
                Text("\(conversation.name)")
            }
        }
    }

    private func deleteButton(for conversation: Conversation) -> some View {
        Button(role: .destructive) {
            Task {
                let success = await viewModel.deleteConversation(conversationId: conversation.id)
                if success {
                    loadConversations()
                }
            }
        } label: {
            Label("Eliminar", systemImage: "trash")
        }
    }

    private func editButton(for conversation: Conversation) -> some View {
        Button {
            if isEditing && editingConversationId == conversation.id {
                saveConversationChanges(for: conversation)
            } else if isEditing {
                cancelEditing()
            } else {
                beginEditing(conversation)
            }
        } label: {
            Label(isEditing && editingConversationId != nil && editingConversationId == conversation.id ? "Guardar" : "Editar", systemImage: "pencil")
        }
    }

    private func saveConversationChanges(for conversation: Conversation) {
        Task {
            let success = await viewModel.updateConversationName(conversationId: conversation.id, newName: updatedConversationName)
            if success {
                loadConversations()
            }
            editingConversationId = nil
            isEditing = false
        }
    }

    private func cancelEditing() {
        editingConversationId = nil
        isEditing = false
    }

    private func beginEditing(_ conversation: Conversation) {
        updatedConversationName = conversation.name
        editingConversationId = conversation.id
        isEditing = true
    }
}

struct MyChatsView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
