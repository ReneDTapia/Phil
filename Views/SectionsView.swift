import SwiftUI
import WebKit

struct SectionsView: View {
    let topicID : Int
    let topicTitle: String
    @State private var progress: Float = 0.6
    @State private var showMenu = false
    @StateObject var SectionsVM = SectionsViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoading = true
    
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
                                Image(systemName: "arrow.left")
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
                        Text(topicTitle)
                            .font(.largeTitle)
                            .bold()
                            .padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 10))
                            .foregroundColor(.white)
                        
                        if isLoading{
                            ProgressView("Cargando...")
                                .progressViewStyle(CircularProgressViewStyle())
                                .foregroundColor(Color.white)
                                .frame(width: geometry.size.width, height: geometry.size.height-100)
                        }
                        List(SectionsVM.resultSections){content in
                            Sections(text: content.text ?? "", video: content.video ?? "", image: content.image ?? "")
                                .listRowBackground(Color.black)
                                .frame(maxWidth:.infinity, alignment:.center)
                                .listRowSeparator(.hidden)
                        }
                        .background(.black)
                        .onAppear{
                            Task{
                                do{
                                    try await SectionsVM.getSections(topicIDVM: topicID)
                                    isLoading = false
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
                            .offset(x:showMenu ? 0 : UIScreen.main.bounds.width * -1)
                            .frame(width: 300, height: geometry.size.height+120)
                }
                
            }
        }
    }
    
    
}



struct Sections: View{
    
    let text : String
    let video : String
    let image: String
    
    var body: some View{
        
        ZStack(alignment: .center) {
            VStack{
                
                if text != ""{
                    Spacer()
                    Text(text)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
                
                
                if image != ""{
                    Spacer()
                    AsyncImage(url: URL(string: image)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else if phase.error != nil {
                            Text("Error loading image")
                        } else {
                            ProgressView()
                        }
                    }
                    .frame(width: 350, height: 190 )
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                }
                
                if video != ""{
                    Spacer()
                    Video(url: video)
                        .frame(width: 350, height: 190 )
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                    Spacer()
                }
                
                Rectangle()
                    .foregroundColor(Color.white)
                    .frame(width: 350,height: 3)
                
                
            }
            
            
        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 5, trailing: 20))
        
        .frame(maxWidth: 500)
    }
}

struct Video: UIViewRepresentable {
    let url: String
    let id: String
        
    init(url: String) {
        self.url = url
        self.id = extractYouTubeVideoID(from: url) ?? ""
    }
        
     
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        guard let YouTubeURL = URL(string: "https://www.youtube.com/embed/\(id)") else
        {return}
        
        uiView.scrollView.isScrollEnabled = false
        uiView.load(URLRequest(url: YouTubeURL))
    }
}

func extractYouTubeVideoID(from url: String) -> String? {
    let pattern = "v=([A-Za-z0-9_-]+)"
    
    if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
        let range = NSRange(location: 0, length: url.count)
        if let match = regex.firstMatch(in: url, options: [], range: range) {
            let idRange = Range(match.range(at: 1), in: url)
            if let idRange = idRange {
                let videoID = String(url[idRange])
                return videoID
            }
        }
    }
    
    return nil
}

struct Sections_Previews: PreviewProvider {
    static var previews: some View {
        SectionsView(topicID: 2, topicTitle: "Titulo del topico")
    }
}

