import SwiftUI

struct TopicsView: View {
    let contentID : Int
    let contentTitle: String
    @State private var progress: Float = 0.6
    @State private var showMenu = false
    @StateObject var TopicsVM = TopicsViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoading = true
    @State private var messageLoad = "Cargando..."
    
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack(alignment: .leading) {
                    Color.black
                        .ignoresSafeArea(.all)
                    VStack(alignment: .leading) {
                        
                        HStack{
                            Button(action: {
                                withAnimation {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }) {
                                Image(systemName: "arrow.left.circle")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                            .padding(EdgeInsets(top: -10, leading: 20, bottom: 0, trailing: 20))
                            
                            Spacer()
                        }
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
                        .padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
                        Text("Temas del contenido")
                            .font(.largeTitle)
                            .bold()
                            .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 10))
                            .foregroundColor(.white)
                        Text(contentTitle)
                            .font(.title)
                            .bold()
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 10))
                            .foregroundColor(.white)
                        if isLoading{
                            ProgressView(messageLoad)
                                .foregroundColor(Color.white)
                                .frame(width: geometry.size.width, height: geometry.size.height-160)
                            
                            .scaleEffect(1.5)
                        }
                        List(TopicsVM.resultTopics){content in
                            
                            NavigationLink(destination: SectionsView(topicID: content.id, topicTitle: content.title)){
                                Topics(title: content.title, description: content.description)
                                    .listRowBackground(Color.black)
                                    .frame(maxWidth:.infinity, alignment:.center)
                                .listRowSeparator(.hidden)}
                            .listRowBackground(Color.black)
                            .frame(maxWidth:.infinity, alignment:.center)
                        .listRowSeparator(.hidden)
                            
                        }
                        .background(.black)
                        .onAppear{
                            Task{
                                do{
                                    try await TopicsVM.getTopics(contentIDVM: contentID)
                                    if TopicsVM.resultTopics.isEmpty {
                                        messageLoad = "No hay datos"
                                        
                                    }
                                    isLoading = TopicsVM.resultTopics.isEmpty // Verifica si la lista está vacía
                                }
                                catch{
                                    print("error")
                                }
                            }
                        }
                        .frame(height: geometry.size.height-170)
                        .listStyle(PlainListStyle())
                          
                        Spacer()
                        
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
                    
                        Menu(showMenu: $showMenu)
                        .offset(x:showMenu ? 0 : UIScreen.main.bounds.width * -1, y:0)
                        .frame(width: 300, height:.infinity)
                        .ignoresSafeArea(.all)
                         
                    
                    
                    
                    
                    
                }
                
            }
            
        }
    }
    
    
}

struct Topics: View{
    
    let title : String
    let description: String
    let isChecked: Bool = false
    
    var body: some View{
        
        ZStack(alignment: .center) {
            Rectangle()
                .foregroundColor(.clear)
                .background(Color(red: 0.96, green: 0.76, blue: 0.30))
                .cornerRadius(24)
                .offset(x: 4, y: 2.50)
            Rectangle()
                .foregroundColor(.clear)
                .background(.white)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .inset(by: 2)
                        .stroke(Color(red: 0.96, green: 0.76, blue: 0.30), lineWidth: 5)
                )
                .offset(x: -4, y: -2.50)
            HStack(){
                VStack(alignment: .leading){
                    Text(title)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                     
                    HStack{
                        Text(description)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(alignment:.leading)
                       
                    
                    
                }
                .padding(EdgeInsets(top: 10, leading: 15, bottom: 20, trailing: 0))
                .frame(maxWidth:.infinity, alignment: .leading)
                 
                 
                ZStack{
                    Image(systemName: isChecked ? "checkmark.square" : "square")
                        .foregroundColor(Color(red: 0.42, green: 0.43, blue: 0.67))
                        .bold()
                        .font(.title)
                        .offset(x: -20)
                        .padding(.leading, 10)
                      
                }
            }
            
        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 5, trailing: 20))
        
        .frame(maxWidth: 500)
    }
}
 

struct Topics_Previews: PreviewProvider {
    static var previews: some View {
        TopicsView(contentID: 1, contentTitle: "adsad")
    }
}
