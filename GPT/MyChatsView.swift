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
    @State private var showSearch = false
    @State private var searchText = ""
    @State private var filteredConversations: [Conversation] = []
    
    // Stats
    @State private var gemCount = 245
    @State private var xpCount = 1240
    @State private var streakDays = 8
    @State private var dailyProgress = 3
    @State private var dailyTotal = 5

    var userId: Int

    @Environment(\.presentationMode) var presentationMode
    @State private var navigateBack = false
    @State private var activeConversation: Conversation? = nil
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                // Header with title and buttons
                headerView
                
                // Stats bar
                statsBar
                
                // Daily challenge
                // dailyChallengeView
                
                // Chats list
                if isLoading {
                    loadingView
                } else {
                    conversationsList
                }
                
                Spacer()
            }
            .onAppear {
                loadConversations()
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var headerView: some View {
        HStack {
            Text("Chats")
                .font(.largeTitle)
                .bold()
                .padding()
            
            Spacer()
            
            Button(action: { self.showSearch.toggle() }) {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.indigo.opacity(0.5))
                    .clipShape(Circle())
            }
            
            Button(action: { self.showModal = true }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.indigo.opacity(0.5))
                    .clipShape(Circle())
            }
            .padding(.trailing)
        }
        .padding(.vertical, 10)
        .background(Color.indigo)
        .foregroundColor(.white)
        .sheet(isPresented: $showModal) {
            ModalView(newConversationName: $newConversationName, addNewConversation: addNewConversation)
                .presentationDetents([.fraction(0.3)])
        }
    }
    
    private var statsBar: some View {
        HStack(spacing: 0) {
            // Gems
            HStack {
                Image(systemName: "dollarsign")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.orange)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.black, lineWidth: 1.5)
                    )
                
                VStack(alignment: .leading) {
                    Text("Gems")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("\(gemCount)")
                        .font(.title3.bold())
                }
                .padding(.leading, 10)
            }
            .frame(maxWidth: .infinity)
            
            // XP
            HStack {
                Image(systemName: "square.3.layers.3d")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.indigo)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.black, lineWidth: 1.5)
                    )
                
                VStack(alignment: .leading) {
                    Text("XP")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("\(xpCount)")
                        .font(.title3.bold())
                        
                }
                .padding(.leading, 10)
            }
            .frame(maxWidth: .infinity)
            
            // Streak
            HStack {
                Image(systemName: "bolt.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.red)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.black, lineWidth: 1.5)
                    )
                
                VStack(alignment: .leading) {
                    Text("Streak")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("\(streakDays) days")
                        .font(.title3.bold())
                        
                }
                .padding(.leading, 10)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color.white)
        .colorScheme(.light)
        .environment(\.colorScheme, .light)
    }
    
    private var dailyChallengeView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "clock")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.indigo)
                    .clipShape(Circle())
                    .padding(.leading)
                
                VStack(alignment: .leading) {
                    Text("Daily Challenge")
                        .font(.title2)
                        .bold()
                    Text("Complete a mindfulness session")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Text("+20 XP")
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.indigo)
                        .cornerRadius(20)
                }
                .padding(.trailing)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 8)
                        .opacity(0.2)
                        .foregroundColor(Color.gray)
                    
                    Rectangle()
                        .frame(width: geometry.size.width * CGFloat(dailyProgress) / CGFloat(dailyTotal), height: 8)
                        .foregroundColor(Color.indigo)
                }
                .cornerRadius(4)
            }
            .padding(.horizontal)
            .frame(height: 8)
            
            Text("\(dailyProgress)/\(dailyTotal) completed")
                .font(.footnote)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing)
                .padding(.bottom, 10)
        }
        .padding(.vertical)
        .background(Color(UIColor.systemGray6))
    }
    
    private var loadingView: some View {
        VStack {
            Spacer()
            if messageLoad == "Cargando..." {
                ProgressView(messageLoad)
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            } else {
                Text(messageLoad)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
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
            filteredConversations = viewModel.conversations
        }
    }
    
    private var conversationsList: some View {
        List {
            if showSearch {
                TextField("Buscar...", text: $searchText)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.vertical, 8)
                    .onChange(of: searchText) { newValue in
                        if newValue.isEmpty {
                            filteredConversations = viewModel.conversations
                        } else {
                            filteredConversations = viewModel.conversations.filter { conversation in
                                conversation.name.localizedCaseInsensitiveContains(newValue)
                            }
                        }
                    }
            }
            ForEach(showSearch ? filteredConversations : viewModel.conversations, id: \.id) { conversation in
                conversationLink(for: conversation)
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private func chatCategory(name: String, time: String, message: String, unread: Int = 0) -> some View {
        NavigationLink(destination: Text("Chat details for \(name)")) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(name)
                            .font(.headline)
                            .bold()
                        
                        Spacer()
                        
                        Text(time)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
//                if unread > 0 {
//                    Spacer()
//                    
//                    Text("\(unread)")
//                        .font(.headline)
//                        .bold()
//                        .foregroundColor(.white)
//                        .frame(width: 30, height: 30)
//                        .background(Color.indigo)
//                        .clipShape(Circle())
//                }
            }
            .padding(.vertical, 8)
        }
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.width > 100 {
                        
                        
                    }
                }
        )
    }

    private func conversationLink(for conversation: Conversation) -> some View {
        NavigationLink(destination: GPTView(conversationId: conversation.id, userId: userId)) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(conversation.name)
                            .font(.headline)
                            .bold()
                        
                        Spacer()
                        
                        Text(formatTimestamp(conversation.lastMessageAt))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Text("Último mensaje: \(conversation.lastMessageAt ?? "No hay mensajes")")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            .padding(.vertical, 8)
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

    private func formatTimestamp(_ timestamp: String?) -> String {
        guard let timestamp = timestamp else { return "No date" }
        
        // This is a simple formatter, you can enhance it based on your API date format
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Adjust based on your API date format
        
        if let date = formatter.date(from: timestamp) {
            let calendar = Calendar.current
            let now = Date()
            
            if calendar.isDateInToday(date) {
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "h:mm a"
                return timeFormatter.string(from: date)
            } else if calendar.isDateInYesterday(date) {
                return "Yesterday"
            } else {
                let weekdayFormatter = DateFormatter()
                weekdayFormatter.dateFormat = "EEEE"
                return weekdayFormatter.string(from: date)
            }
        }
        
        return timestamp
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

struct MyChatsView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
