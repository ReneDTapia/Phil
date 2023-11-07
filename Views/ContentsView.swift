import SwiftUI

struct ContentsView: View {
    
    let user = 2
    
    @State private var progress: Double = 1
    @State private var showMenu = false
    @StateObject var ContentVM = ContentsViewModel()
    @State private var isLoading = true
    @State private var messageLoad = "Cargando..."
    
    var body: some View {
    GeometryReader { geometry in
        NavigationStack {
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
                    Text("Contenidos")
                        .font(.largeTitle)
                        .bold()
                        .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 10))
                        .foregroundColor(.white)
                    if isLoading{
                        ProgressView(messageLoad)
                            .foregroundColor(Color.white)
                            .frame(width: geometry.size.width, height: geometry.size.height-100)
                        
                        .scaleEffect(1.5)
                    }
                    List(ContentVM.resultContents, id:\.id){content in
                        NavigationLink(destination: TopicsView(contentID: content.id, contentTitle: content.title, user: user)){
                            Contents(title: content.title, description: content.description, progress: content.proporcion ?? 0)
                                .listRowBackground(Color.black)
                                .frame(maxWidth:.infinity, alignment:.center)
                                .listRowSeparator(.hidden)
                                .navigationBarHidden(false)
                                .navigationBarBackButtonHidden(false)
                        }
                        .listRowBackground(Color.black)
                        .frame(maxWidth:.infinity, alignment:.center)
                        .listRowSeparator(.hidden)
                        .navigationBarHidden(false)
                        .navigationBarBackButtonHidden(false)
                    }
                    .background(.black)
                    .onAppear{
                        Task{
                            do{
                                try await ContentVM.getContents(userIDVM: user)
                                if ContentVM.resultContents.isEmpty {
                                    messageLoad = "No hay datos"
                                    
                                }
                                isLoading = ContentVM.resultContents.isEmpty // Verifica si la lista está vacía
                            }
                            catch{
                                print("error")
                            }
                        }
                    }
                    .frame(height: geometry.size.height-90)
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
                
                HStack{
                    Menu(showMenu: $showMenu)
                        .offset(x:showMenu ? 0 : UIScreen.main.bounds.width * -1, y:0)
                        .frame(width: 300, height:.infinity)
                        .ignoresSafeArea(.all)
                    
                }
                
                
                
                
            }
            
        }
    }
    }
    
    
}

struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                
                Rectangle()
                    .frame(width: geometry.size.width, height: 12)
                    .cornerRadius(4)
                    .foregroundColor(.clear)
                    .background(Color(red: 0.42, green: 0.43, blue: 0.67))
                    .cornerRadius(24)
                    .opacity(0.3)
                
                Rectangle()
                    .frame(width: min(CGFloat(self.progress) * geometry.size.width-5, geometry.size.width), height: 7)
                    .foregroundColor(.clear)
                    .background(Color(red: 0.42, green: 0.43, blue: 0.67))
                    .cornerRadius(4)
                    .padding(2)
            }
        }
    }
}

struct Contents: View{
    
    //@Binding var progress: Float
    
    let title : String
    let description: String
    let progress: Double
    
    var body: some View{
        
        ZStack(alignment: .center) {
            Rectangle()
                .foregroundColor(.clear)
                .background(Color(red: 0.42, green: 0.43, blue: 0.67))
                .cornerRadius(24)
                .offset(x: 4, y: 2.50)
            Rectangle()
                .foregroundColor(.clear)
                .background(.white)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .inset(by: 2)
                        .stroke(Color(red: 0.42, green: 0.43, blue: 0.67), lineWidth: 5)
                )
                .offset(x: -4, y: -2.50)
            
            VStack(alignment: .leading){
                Text(title)
                    .font(.title)
                    .bold()
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                Text(description)
                    .foregroundColor(.gray)
                    .padding(.trailing,5)
                ProgressBar(progress: progress)
                    .frame(height: 10)
                    .padding(.trailing, 10)
                HStack{
                    
                    if progress == 1{
                        Text("Completado!")
                            .foregroundColor(.gray)
                    } else if progress == 0{
                        Text("No haz comenzado!")
                            .foregroundColor(.gray)
                    }else if progress == 0.5{
                        Text("Ya estas por la mitad!")
                            .foregroundColor(.gray)
                    }
                    else if progress > 0 && progress < 0.5{
                        Text("Sigue asi!")
                            .foregroundColor(.gray)
                    }
                    else if progress > 0.5 && progress < 1{
                        Text("Ya casi llegas!")
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    Text("\(String(format:"%.0f",progress*100))%")
                        .foregroundColor(.gray)
                }
            }
            .padding()
        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 5, trailing: 20))
        
        .frame(maxWidth: 500)
    }
}

struct Menu: View {
    @Binding var showMenu: Bool
    @State var progress: Double = 0.5
    var body: some View {
        
    
            ZStack{
                Color(red: 0.96, green: 0.96, blue: 1)
                
                VStack{
        
                
                    Text("Phil")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.black)
                        .padding(.top, 100)
                    Divider()
                        .frame(height: 2)
                        .background(Color.black)
                    
                    
                    Text("Daily Objectives")
                        .font(.title)
                        .bold()
                        .foregroundColor(.black)
                    
                    ProgressBar(progress: progress)
                        .frame(height: 10)
                    Text("Almost There")
                        .foregroundColor(.black)
                    
                    VStack(alignment:.leading){
                
                        NavigationStack{
                            
                            List{
                        
                                //////
                                ///
                                ///
                                NavigationLink(destination : InitialFormView()){
                                    HStack{
                                        Image(systemName: "person.fill")
                                        Text("Tu")
                                        Spacer()
                                    }
                                    .foregroundColor(.black)
                                    .padding()
                                }.navigationBarHidden(true)
                                    .listRowBackground(Color(red: 0.96, green: 0.96, blue: 1))
                                    .navigationBarBackButtonHidden(true)
                                
                                NavigationLink(destination : ContentsView()){
                                    HStack{
                                        Image(systemName: "star.fill")
                                        Text("Contenidos")
                                        Spacer()
                                    }
                                    .foregroundColor(.black)
                                    .padding()
                                }.navigationBarHidden(true)
                                    .listRowBackground(Color(red: 0.96, green: 0.96, blue: 1))
                                    .navigationBarBackButtonHidden(true)
                                
                                
                                NavigationLink(destination : PictureView()){
                                    HStack{
                                        Image(systemName: "photo.fill")
                                        Text("Tus fotos")
                                        Spacer()
                                    }
                                    .foregroundColor(.black)
                                    .padding()
                                }.navigationBarHidden(true)
                                    .listRowBackground(Color(red: 0.96, green: 0.96, blue: 1))
                                    .navigationBarBackButtonHidden(true)
                                
                                NavigationLink(destination : MyChatsView(userId: 1)){
                                    HStack{
                                        Image(systemName: "message")
                                        Text("Chatea con Phil")
                                        Spacer()
                                    }
                                    .foregroundColor(.black)
                                    .padding()
                                }.navigationBarHidden(true)
                                    .listRowBackground(Color(red: 0.96, green: 0.96, blue: 1))
                                    .navigationBarBackButtonHidden(true)

                                
                                
                                NavigationLink(destination : MyChatsView(userId: 1)){
                                    HStack{
                                        Image(systemName: "photo.fill")
                                        Text("Tus fotos")
                                        Spacer()
                                    }
                                    .foregroundColor(.black)
                                    .padding()
                                }.navigationBarHidden(true)
                                    .listRowBackground(Color(red: 0.96, green: 0.96, blue: 1))
                                    .navigationBarBackButtonHidden(true)
                                
                                
                                
                                
                            }.listStyle(PlainListStyle())
                                .background(Color(red: 0.96, green: 0.96, blue: 1))
                            
                            
                            
                            
                        }.navigationBarHidden(true)
                            .navigationBarBackButtonHidden(true)
                            .frame(width: 250)
                        
                        //////
                    }
                    
                
                .padding(16)
                .edgesIgnoringSafeArea(.all)
                
            }
            .frame(width: 250)
            .frame(maxWidth: 250)
        }
    }
}

struct Contents_Previews: PreviewProvider {
    static var previews: some View {
        ContentsView()
    }
}
