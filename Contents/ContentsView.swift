import SwiftUI
import Foundation

struct ContentsView: View {
    let user: Int
    
    @State private var progress: Double = 1
    @State private var showMenu = false
    @StateObject var ContentVM = ContentsViewModel()
    @State private var isLoading = true
    @State private var messageLoad = "Cargando..."
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack { 
                ZStack(alignment: .leading) {
                    Color.white.edgesIgnoringSafeArea(.all)
                    
                    VStack(alignment: .leading) {
                        HStack{
                            Text("Phil")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.black)
                            Spacer() 
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 40, height: 40)
                            }
                        }
                        .padding()
                        
                        if isLoading{
                            Spacer()
                            if messageLoad == "Cargando..." {
                                ProgressView(messageLoad)
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .frame(width: geometry.size.width)
                                    .scaleEffect(1.5)
                                Spacer()
                            } else {
                                Spacer()
                                Text(messageLoad)
                                    .frame(width: geometry.size.width)
                                    .scaleEffect(1.5)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Spacer()
                            }
                        }
                        else{
                            // Content view when loaded
                            VStack(alignment: .leading, spacing: 8){ 
                                Text("Continue Learning")
                                    .font(.title2)
                                    .bold()
                                    .padding(.horizontal, 16)
                                    .padding(.top, 8)
                                    .foregroundColor(.primary)
                                
                                ScrollView {
                                    LazyVStack(spacing: 8) {
                                        ForEach(ContentVM.resultContents, id:\.id) { content in
                                            NavigationLink(destination: TopicsView(
                                                contentID: content.id,
                                                contentTitle: content.title,
                                                user: user,
                                                contentImageURL: content.thumbnail_url
                                            )) {
                                                Contents(
                                                    title: content.title,
                                                    description: content.description,
                                                    progress: content.proporcion ?? 0,
                                                    thumbnail_url: content.thumbnail_url
                                                )
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .padding(.bottom, 16)
                                }
                                .background(Color.white)
                            }
                            .background(Color.white)
                        }
                    }
                }
                .background(Color.white)
            }
            .onAppear{
                Task{
                    do{
                        try await ContentVM.getContents(userIDVM: user)
                        if ContentVM.resultContents.isEmpty {
                            messageLoad = "No hay datos"
                        }
                        isLoading = ContentVM.resultContents.isEmpty
                    }
                    catch{
                        print("Error: \(error)")
                    }
                }
            }
            .background(Color.white)
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }
}

struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .cornerRadius(geometry.size.height / 2)
                    .foregroundColor(Color(.systemGray5))
                
                Rectangle()
                    .frame(width: min(CGFloat(self.progress) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .cornerRadius(geometry.size.height / 2)
                    .foregroundColor(Color.indigo)
            }
        }
    }
}

struct Contents: View{  
    
    let title : String
    let description: String
    let progress: Double
    let thumbnail_url: String
    
    var body: some View{
        VStack(alignment: .leading, spacing: 0) {
            // Image with title overlay
            ZStack(alignment: .bottomLeading) {
                // Image placeholder with gradient overlay
                Rectangle()
                    .foregroundColor(Color(.systemGray5))
                    .frame(height: 180)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.5)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        contentImage
                    )
                
                // Title overlay on image
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                // Description
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.top, 16)
                
                // Progress section
                VStack(alignment: .leading, spacing: 6) {
                    Text("Progress")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ProgressBar(progress: progress)
                        .frame(height: 8)
                    
                    Text("\(Int(progress * 100))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                // Bottom row
                HStack {
                    Text("3 lessons")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("Continue")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.indigo)
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(Color.indigo)
                    }
                }
                .padding(.vertical, 8)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    // Helper computed property for the content image
    private var contentImage: some View {
        Group {
            let processedURL = APIClient.getFullImageURL(thumbnail_url)
            
            if let url = URL(string: processedURL) {
                loadImageFromURL(url)
            } else if let escapedURL = processedURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                      let url = URL(string: escapedURL) {
                loadImageFromURL(url)
                    .onAppear {
                        print("Contents card using escaped URL: \(escapedURL)")
                    }
            } else {
                Color.gray
                    .frame(height: 180)
                    .onAppear {
                        print("Invalid URL even after escaping in Contents card: \(processedURL)")
                    }
            }
        }
    }
    
    // Helper function to load images
    @ViewBuilder
    private func loadImageFromURL(_ url: URL) -> some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .clipped()
        } placeholder: {
            Color.gray
                .frame(height: 180)
                .overlay(
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(.white)
                )
        }
        .onAppear {
            print("Contents card loading image from URL: \(url)")
        }
    }
}

// Add extension for rounded specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
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

struct Contents_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

