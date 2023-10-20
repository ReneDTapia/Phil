import SwiftUI

struct ContentsView: View {
    
    @State private var progress: Float = 1
    @State private var showMenu = false
    @StateObject var ContentVM = ContentsViewModel()
    
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
                    .padding(EdgeInsets(top: 100, leading: 20, bottom: 0, trailing: 20))
                    Text("Contenidos")
                        .font(.largeTitle)
                        .bold()
                        .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 10))
                        .foregroundColor(.white)
                    
                    List(ContentVM.resultContents){content in
                        NavigationLink(destination: TopicsView(contentID: content.id, contentTitle: content.title)){
                            Content(progress: $progress, title: content.title, description: content.description)
                                .listRowBackground(Color.black)
                                .frame(maxWidth:.infinity, alignment:.center)
                                .listRowSeparator(.hidden)
                                  
                        }
                        .listRowBackground(Color.black)
                        .frame(maxWidth:.infinity, alignment:.center)
                        .listRowSeparator(.hidden)
                    }
                    .background(.black)
                    .onAppear{
                        Task{
                            do{
                                try await ContentVM.getContents()
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
                        .offset(x:showMenu ? 0 : UIScreen.main.bounds.width * -1)
                    
                }
                
                
                
                
            }
            
        }
    }
    }
    
    
}

struct ProgressBar: View {
    @Binding var progress: Float
    
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

struct Content: View{
    
    @Binding var progress: Float
    
    let title : String
    let description: String
    
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
                    .font(/@START_MENU_TOKEN@/.title/@END_MENU_TOKEN@/)
                    .bold()
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                Text(description)
                    .foregroundColor(.gray)
                    .padding(.trailing,5)
                ProgressBar(progress: $progress)
                    .frame(height: 10)
                    .padding(.trailing, 10)
                HStack{
                    Text("Completed!")
                        .foregroundColor(.gray)
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
    @State var progress: Float = 0.5
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
                    .font(/@START_MENU_TOKEN@/.title/@END_MENU_TOKEN@/)
                    .bold()
                    .foregroundColor(.black)
                
                ProgressBar(progress: $progress)
                    .frame(height: 10)
                Text("Almost There")
                    .foregroundColor(.black)
                
                VStack(alignment:.leading){
                    HStack{
                        Image(systemName: "star.fill")
                        Text("Menu 1")
                        Spacer()
                    }
                    .foregroundColor(.black)
                    .padding()
                    HStack{
                        Image(systemName: "star.fill")
                        Text("Menu 1")
                    }
                    .foregroundColor(.black)
                    .padding()
                    
                    HStack{
                        Image(systemName: "star.fill")
                        Text("Menu 1")
                    }
                    .foregroundColor(.black)
                    .padding()
                    
                    HStack{
                        Image(systemName: "star.fill")
                        Text("Menu 1")
                    }
                    .foregroundColor(.black)
                    .padding()
                    
                    HStack{
                        Image(systemName: "star.fill")
                        Text("Menu 1")
                    }
                    .foregroundColor(.black)
                    .padding()
                }
                
            }
            .padding(16)
            .edgesIgnoringSafeArea(.bottom)
            
        }
        .frame(width: 250)
    }
}
