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
                        headerView
                        addButton
                        newConversationField
                        Spacer()
                        if isLoading {
                            loadingView(geometry: geometry)
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
        Text("Chatea con Phil")
            .font(.largeTitle)
            .bold()
            .padding(.top, 20)
            .padding(.horizontal, 20)
            .foregroundColor(.white)
    }

    private var addButton: some View {
        HStack {
            Spacer()
            Button(action: { showingAddConversation.toggle() }) {
                Image(systemName: "plus")
                    .padding()
                    .foregroundColor(.white)
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
            }
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
            messageLoad = viewModel.conversations.isEmpty ? "No hay datos" : "Cargando..."
        }
    }

    private func loadingView(geometry: GeometryProxy) -> some View {
        ProgressView(messageLoad)
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .foregroundColor(Color.white)
            .frame(width: geometry.size.width, height: geometry.size.height - 100)
            .scaleEffect(1.5)
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
        .listRowBackground(Color.black)
    }

    private func conversationNameView(_ conversation: Conversation) -> some View {
        Group {
            if isEditing && editingConversationId == conversation.id {
                TextField("Nuevo nombre", text: $updatedConversationName)
                    .foregroundColor(Color.white)
            } else {
                Text("\(conversation.name)")
                    .foregroundColor(Color.white)
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
        MyChatsView(userId: 1)
    }
}
