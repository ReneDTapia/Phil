import SwiftUI
import Foundation

struct ContentsView: View {
    
    let user : Int
    
    @State private var progress: Double = 1
    @State private var showMenu = false
    @StateObject var ContentVM = ContentsViewModel()
    @State private var isLoading = true
    @State private var messageLoad = "Cargando..."
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        
                        Text("Contenidos")
                            .font(.largeTitle)
                            .bold()
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
                            List(ContentVM.resultContents, id:\.id){content in
                                NavigationLink(destination: TopicsView(contentID: content.id, contentTitle: content.title, user: user)){
                                    Contents(title: content.title, description: content.description, progress: content.proporcion ?? 0)
                                        .frame(maxWidth:.infinity, alignment:.center)
                                        .listRowSeparator(.hidden)
                                        .navigationBarHidden(false)
                                        .navigationBarBackButtonHidden(true)
                                }
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
                                .frame(maxWidth:.infinity, alignment:.center)
                                .listRowSeparator(.hidden)
                                .navigationBarHidden(false)
                                .navigationBarBackButtonHidden(true)
                            }
                            .frame(height: geometry.size.height-100)
                            
                            Spacer()
                        }
                        
                        
                        
                        
                        
                    }
                    
                }
                .navigationBarHidden(false)
            }
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
            .listStyle(PlainListStyle())
            
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
                    .background(.indigo)
                    .cornerRadius(24)
                    .opacity(0.3)
                
                Rectangle()
                    .frame(width: min(CGFloat(self.progress) * geometry.size.width-5, geometry.size.width), height: 7)
                    .foregroundColor(.clear)
                    .background(.indigo)
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
                .background(.indigo)
                .cornerRadius(24)
                .offset(x: 4, y: 2.50)
            Rectangle()
                .foregroundColor(.clear)
                .background(.white.opacity(0.95))
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .inset(by: 2)
                        .stroke(.indigo, lineWidth: 5)
                )
                .offset(x: -4, y: -2.50)
            
            VStack(alignment: .leading){
                Text(title)
                    .font(.title2)
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
    @StateObject var LoginVM = LoginViewModel()
    let user: Int
    @State private var showInitialFormView = false
    @State private var showPerfilView = false
    @State private var showUserView = false
    @ObservedObject var loginViewModel = LoginViewModel()

    var body: some View {
        ZStack{
            Color(hex:"F6F6FE")
            VStack{
                Text("Phil")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.black)
                    .padding(.top, 100)
                Divider()
                    .frame(height: 2)
                    .background(Color.black)
                Text("Objetivos Diarios")
                    .font(.title)
                    .bold()
                    .foregroundColor(.black)
                    .padding(.bottom, 10)
                ProgressBar(progress: progress)
                    .frame(height: 10)
                Text("Mi Progreso")
                    .foregroundColor(.black)
                VStack(alignment:.leading){
                    NavigationStack{
                            Button(action: {
                                self.showPerfilView = true
                            }) {
                                HStack{
                                    Image(systemName: "person.fill")
                                    Text("Perfil")
                                    Spacer()
                                }
                                .foregroundColor(.black)
                                .padding()
                                
                            }
                            .background(Color(hex:"F6F6FE"))
                            .padding(.bottom,-10)
                            .fullScreenCover(isPresented: $showPerfilView) {
                                UserView(userId: user)
                            }
                            Button(action: {
                                self.showInitialFormView = true
                            }) {
                                HStack{
                                    Image(systemName: "square.and.pencil")
                                    Text("Mi estado")
                                    Spacer()
                                }
                                .foregroundColor(.black)
                                .padding()
                                
                            }
                            .background(Color(hex:"F6F6FE"))
                            .padding(.bottom,-10)
                            .fullScreenCover(isPresented: $showInitialFormView) {
                                InitialFormView(userId: user)
                            }
                            Color(hex:"F6F6FE")
                            .padding(.bottom,-10)
                            
                            Button(action: {
                                LoginVM.logout()
                                LoginVM.viewState = .username
                                self.showUserView = true
                                UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: MainView())
                            }) {
                                HStack{
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                    Text("Salir")
                                    Spacer()
                                }
                                .foregroundColor(.black)
                                .padding()
                                
                            }
                            
                            .background(Color(hex:"F6F6FE"))
                            .fullScreenCover(isPresented: $showUserView) {
                                UsernameView(viewModel: loginViewModel)
                            }
                            
                            
                        
                        
                    }
                    .navigationBarHidden(false)
                    .navigationBarBackButtonHidden(true)
                    .frame(width: 250)
                    .background(Color(hex:"F6F6FE"))
                }
                .padding(16)
                .edgesIgnoringSafeArea(.all)
                
            }
            .frame(width: 250)
            .frame(maxWidth: 250)
            
        }
    }
}


//    .frame(width: 250)
//    .frame(maxWidth: 250)

    

struct Contents_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

//#Preview{
   // TabBarView(user: 1)
//}
