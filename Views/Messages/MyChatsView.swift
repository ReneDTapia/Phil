import SwiftUI

struct MyChatsView: View {
    @StateObject var viewModel: ChatViewModel
    var userId: Int

    @State private var showMenu = false
    
    
    var body: some View {
        NavigationView {
            
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
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
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
                        
                        List(viewModel.conversations) { conversation in
                            NavigationLink(destination: ChatView(viewModel: viewModel, conversationId: conversation.id)) {
                                VStack(alignment: .leading) {
                                    Text("Conversación \(conversation.id)")
                                        .foregroundColor(Color.white)
                                    Text("Último mensaje: \(conversation.lastMessageAt)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }.listRowBackground(Color.black)
                        }.listStyle(PlainListStyle())
                        
                        
                        .onAppear {
                            viewModel.fetchConversations(userId: 1)
                        }
                        
                        
                        
                        //SECCION DE MIS CONVERSACIONES
                    
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
                        
                    }
                    
                }
            }
            
            
            
            
            
            
            
            /////
            
           
        }
    }
}

struct MyChatsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ChatViewModel()
        return MyChatsView(viewModel: viewModel, userId: 1)
    }
}

