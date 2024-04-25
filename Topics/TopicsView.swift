import SwiftUI

struct TopicsView: View {
    let contentID : Int
    let contentTitle: String
    let user: Int
    @State private var showMenu = false
    @StateObject var TopicsVM = TopicsViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoading = true
    @State private var messageLoad = "Cargando..."
    
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
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
                        
                        Text("Temas del contenido")
                            .font(.largeTitle)
                            .bold()
                            .padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 10))
                        Text(contentTitle)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 10))
 
                        if isLoading{
                            if messageLoad == "Cargando..." {
                                ProgressView(messageLoad)
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .frame(width: geometry.size.width, height: geometry.size.height - 100)
                                    .scaleEffect(1.5)
                            } else {
                                // Devuelve algo como un Text vacío o un Spacer
                                Text(messageLoad)
                                    .frame(width: geometry.size.width, height: geometry.size.height - 100)
                                    .scaleEffect(1.5)
                                    .foregroundColor(.gray)
                                
                            }
                            
                            
                        }
                        else{
                            
                            
                            List(TopicsVM.resultTopics, id:\.topic){content in
                                
                                
                                NavigationLink(destination: SectionsView(topicID: content.topic, topicTitle: content.title, user: user, isChecked: content.done ?? false)){
                                    Topics(title: content.title, description: content.description, isChecked: content.done ?? false, user: user, topic: content.topic)
                                        .frame(maxWidth:.infinity, alignment:.center)
                                    .listRowSeparator(.hidden)}
                            
                                .frame(maxWidth:.infinity, alignment:.center)
                                .listRowSeparator(.hidden)
                                
                            }
                            .frame(height: geometry.size.height-100)
                        }
                        Spacer()
                        
                    }.gesture(
                        DragGesture()
                            .onEnded { value in
                                if value.translation.width > 100 {  // Comprobar deslizamiento hacia la izquierda
                                    withAnimation {
                                        presentationMode.wrappedValue.dismiss()  // Cerrar la vista
                                    }
                                }
                            }
                    )
    
                    
                    
                }
                .onAppear{
                    Task{
                        do{
                            try await TopicsVM.getTopics(contentIDVM: contentID, userIDVM: user)
                            
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
            }
            
            
            .frame(height: geometry.size.height)
            .listStyle(PlainListStyle())
             
                .navigationBarBackButtonHidden(true)
        }
    }
    
}

struct Topics: View{
    
    let title : String
    let description: String
    let isChecked: Bool
    let user: Int
    let topic: Int
    
    @StateObject var TopicsVM = TopicsViewModel()
    
    var body: some View{
        
        ZStack(alignment: .center) {
            Rectangle()
                .foregroundColor(.clear)
                .background(.yellow)
                .cornerRadius(24)
                .offset(x: 4, y: 2.50)
            Rectangle()
                .foregroundColor(.clear)
                .background(.white)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .inset(by: 2)
                        .stroke(.yellow, lineWidth: 5)
                )
                .offset(x: -4, y: -2.50)
            HStack(){
                VStack(alignment: .leading){
                    Text(title)
                        .font(.title2)
                        .foregroundColor(.black)
                        .bold()
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
                 
                 
                ZStack {
                    Image(systemName: isChecked ? "checkmark.square" : "square")
                        .foregroundColor(.indigo)
                        .bold()
                        .font(.title)
                        .offset(x: -20)
                        .padding(.leading, 10)
                        .onTapGesture {
                            TopicsVM.UpdateDone(user: user, topic: topic, done: !isChecked)
                        }
                }
            }
            
        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 5, trailing: 20))
        .frame(maxWidth: 500)

        
    }
}
 

struct Topics_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
