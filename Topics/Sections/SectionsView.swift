import SwiftUI
import WebKit

struct SectionsView: View {
    @Environment(\.managedObjectContext) var moc
    let topicID : Int
    let topicTitle: String
    let user: Int
    let isChecked: Bool
    @State private var progress: Float = 0.6
    @State private var showMenu = false
    @StateObject var SectionsVM = SectionsViewModel()
    @StateObject var TopicsVM = TopicsViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoading = true
    @State private var messageLoad = "Cargando..."
    @State private var checkButton = false
    @State private var exist = false
    
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
                            .padding(EdgeInsets(top: -10, leading: -5, bottom: 0, trailing: 0))
                            
                            Spacer()
                        }
                        
                        .padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
                        Text(topicTitle)
                            .font(.largeTitle)
                            .bold()
                            .padding(EdgeInsets(top: 10, leading: 20, bottom:  10, trailing: 10))
                            .foregroundColor(.white)
                        
                        if isLoading{
                            ProgressView(messageLoad)
                                .foregroundColor(Color.white)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(width: geometry.size.width, height: geometry.size.height-120)
                                .scaleEffect(1.5)
                        }
                        
                        else{
                            
                            List {
                                ForEach(SectionsVM.resultSections, id: \.id) { content in
                                    
                                    Sections(text: content.text ?? "",
                                             video: content.video ?? "",
                                             image: content.image ?? "")
                                        .listRowBackground(Color.black)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .listRowSeparator(.hidden)
                                }
                                HStack{
                                    Spacer()
                                    
                                    Button(action: {
                                        
                                  
                                        
                                        if exist == true{
                                            
                                            
                                            checkButton.toggle()
                                            print(checkButton)
                                            TopicsVM.UpdateDone(user: user, topic: topicID, done: checkButton)
                                        }
                                        else{
                                            exist = true
                                            checkButton.toggle()
                                            TopicsVM.postTopic(user: user, topic: topicID)
                                        }
                                        
                                        
                                        }
                                            ) {
                                                Text(checkButton ? "Deshacer" : "Hecho")
                                                    .padding()
                                                    .foregroundColor(.white)
                                                    .background(checkButton ? Color.red : Color.green)
                                                    .cornerRadius(10)
                                                    
                                            }
                                            .padding(.top,-10)
                                    Spacer()
                                }
                                .listRowBackground(Color.black)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .listRowSeparator(.hidden)
                            }
                            .background(.black)
                            
                            
                        }
                        
                        
                        
                        
                    }
                    
                }
                }
            .onAppear{
                Task{
                    do{
                        try await SectionsVM.getSections(topicIDVM: topicID)
                        if SectionsVM.resultSections.isEmpty {
                            messageLoad = "No hay datos"
                        }
                        isLoading = SectionsVM.resultSections.isEmpty // Verifica si la lista está vacía
                        
                        
                    }
                    catch{
                        print("error")
                    }
                }
            }
            .frame(height: geometry.size.height)
            .listStyle(PlainListStyle())
            
        }
            .navigationBarBackButtonHidden(true)
            .onAppear{
                
                
                checkButton = isChecked
                Task{
                    do{
                        try await TopicsVM.getTopicsStatus(topicIDVM: topicID, userIDVM: user)
                        if TopicsVM.topicStatus.first?.userresult ?? 0 > 0{
                            exist = true
                        }
                        else{
                            exist = false
                        }
                        print(exist)
                    }
                    catch{
                        print("Aca esta el error")
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
                Color.black
                VStack{
                    if text != ""{
                        Text(text)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .padding(.leading)
                            .padding(.trailing)
                            .padding(.top, -15)
                    }
                    
                    
                    if image != ""{
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
                        Video(url: video, autoplay: 1)
                            .frame(width: 350, height: 190 )
                            .cornerRadius(12)
                            .padding(.horizontal, 24)
                    }
                    
                    Rectangle()
                        .foregroundColor(Color.white)
                        .frame(width: 350,height: 3)
                    
                    
                }
                
                
            }
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            .background(Color.black)
            .frame(maxWidth: 500)
        }
}
struct Video: UIViewRepresentable {
    let url: String
    let id: String
    let autoplay: Int
    
    init(url: String, autoplay: Int) {
        self.url = url
        self.id = extractYouTubeVideoID(from: url) ?? ""
        self.autoplay = autoplay
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        guard let YouTubeURL = URL(string: "https://www.youtube.com/embed/\(id)?autoplay=\(String(autoplay))") else {
            return
        }
        
        uiView.scrollView.isScrollEnabled = false
        uiView.load(URLRequest(url: YouTubeURL))
    }
}

struct YouTubeVideoView: View {
    let url: String
    let id: String
    init(url: String) {
        self.url = url
        self.id = extractYouTubeVideoID(from: url) ?? ""
    }

    var body: some View {
        WebView(html: """
            <iframe
                width="100%"
                height="100%"
                src="https://www.youtube.com/embed/\(id)?autoplay=1"
                frameborder="0"
                allowfullscreen
            ></iframe>
        """)
    }
}

struct WebView: UIViewRepresentable {
    let html: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(html, baseURL: nil)
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
 SectionsView(topicID: 1, topicTitle: "Titulo del topico", user: 1, isChecked: false)
 }
 }
 
