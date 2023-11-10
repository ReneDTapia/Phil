import SwiftUI

struct MyChatsView: View {
    @StateObject var viewModel = ChatViewModel()
    @StateObject var GPTviewModel = GPTViewModel()
    
    var userId: Int

    @State private var showMenu = false
    @State private var isLoading = true
    @State private var messageLoad = "Cargando..."
    
    
    var body: some View {
        NavigationStack {
            
            GeometryReader{
                
                geometry in
                
                ZStack(alignment: .leading) {
                    Color.black
                        .ignoresSafeArea(.all)
                    VStack(alignment: .leading) {
                        
                        Text("Chatea con Phil")
                            .font(.largeTitle)
                            .bold()
                            .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 10))
                            .foregroundColor(.white)
                        
                        
                        ////
                        //seccion DE MIS CONVERSACIONES?)
                        
                        Spacer()
                        
                       
                        HStack{
                            Spacer()
                            Button(action: {
                            }) {
                                Image(systemName: "plus").padding()
                            }
                        }
                        
                        if isLoading{ProgressView(messageLoad)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .foregroundColor(Color.white)
                                .frame(width: geometry.size.width, height: geometry.size.height-100)
                            
                                .scaleEffect(1.5)
                            
                            
                        }
                        else{
                            
                            List(viewModel.conversations) { conversation in
                                NavigationLink(destination: GPTView(conversationId: conversation.id, viewModel: GPTviewModel)) {
                                    VStack(alignment: .leading) {
                                        Text("Conversación \(conversation.id)")
                                            .foregroundColor(Color.white)
                                        Text("Último mensaje: \(conversation.lastMessageAt)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }.listRowBackground(Color.black)
                            }.listStyle(PlainListStyle())
                        }
                        
                        
                        
                        
                        //SECCION DE MIS CONVERSACIONES
                    
                    }
                    
                }
            }
            .onAppear {
                Task{
                    await viewModel.fetchConversations(userId: 1)
                    
                    if viewModel.conversations.isEmpty {
                        messageLoad = "No hay datos"
                    }
                    isLoading = viewModel.conversations.isEmpty
                    
                    
                }
            }
                    
        }
                
                
    }
            
}
    


struct MyChatsView_Previews: PreviewProvider {
    static var previews: some View {
        return MyChatsView(userId: 1)
    }
}
