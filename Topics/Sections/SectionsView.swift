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
    @State private var mainContentTitle: String = "Understanding Anxiety" // Título del curso principal (variable)
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack(alignment: .top) {
                    // Fondo general
                    Color.white.edgesIgnoringSafeArea(.all)
                    
                    // Contenido principal
                    VStack(spacing: 0) {
                        // Header con imagen - extendido hasta arriba
                        ZStack(alignment: .bottomLeading) {
                            // Imagen de fondo con gradiente
                            Rectangle()
                                .foregroundColor(Color(.systemGray5))
                                .frame(height: 180)
                                .edgesIgnoringSafeArea(.top)
                                .overlay(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .overlay(
                                    Image(systemName: "photo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.gray)
                                )
                            
                            // Títulos superpuestos
                            VStack(alignment: .leading, spacing: 6) {
                                // Título del curso principal
                                Text(mainContentTitle)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                // Título de la sección actual
                                Text(topicTitle)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        
                        if isLoading {
                            VStack {
                                if messageLoad == "Cargando..." {
                                    ProgressView(messageLoad)
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .scaleEffect(1.5)
                                        .padding(.top, 100)
                                } else {
                                    Text(messageLoad)
                                        .font(.body)
                                        .foregroundColor(.gray)
                                        .padding(.top, 100)
                                }
                            }
                            .frame(width: geometry.size.width, height: 400)
                        } else {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    // Contenido principal
                                    ForEach(SectionsVM.resultSections, id: \.id) { content in
                                        SectionContentView(
                                            text: content.text ?? "",
                                            video: content.video ?? "",
                                            image: content.image ?? ""
                                        )
                                    }
                                    
                                    // Botón de Hecho/Deshacer
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            if exist {
                                                checkButton.toggle()
                                                TopicsVM.UpdateDone(user: user, topic: topicID, done: checkButton)
                                            } else {
                                                exist = true
                                                checkButton.toggle()
                                                TopicsVM.postTopic(user: user, topic: topicID)
                                            }
                                        }) {
                                            Text(checkButton ? "Deshacer" : "Hecho")
                                                .padding()
                                                .bold()
                                                .font(.title3)
                                                .foregroundColor(.white)
                                                .background(checkButton ? Color.red : Color.green)
                                                .cornerRadius(10)
                                        }
                                        .padding(.vertical, 20)
                                        Spacer()
                                    }
                                }
                                .padding(.bottom, 30)
                            }
                        }
                    }
                    
                    // Botón de regreso como overlay
                    VStack {
                        HStack {
                            Button(action: {
                                withAnimation {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Circle().fill(Color.black.opacity(0.3)))
                            }
                            .padding(.top, 0) // Espacio para la interfaz del sistema
                            .padding(.leading, 20)
                            
                            Spacer()
                        }
                        Spacer()
                    }
                    .zIndex(10) // Valor elevado para estar por encima de todo
                }
                .onAppear {
                    Task {
                        do {
                            try await SectionsVM.getSections(topicIDVM: topicID)
                            if SectionsVM.resultSections.isEmpty {
                                messageLoad = "No hay datos"
                            }
                            isLoading = SectionsVM.resultSections.isEmpty
                        } catch {
                            print("error")
                        }
                    }
                    
                    checkButton = isChecked
                    Task {
                        do {
                            try await TopicsVM.getTopicsStatus(topicIDVM: topicID, userIDVM: user)
                            if TopicsVM.topicStatus.first?.userresult ?? 0 > 0 {
                                exist = true
                            } else {
                                exist = false
                            }
                        } catch {
                            print("Error obteniendo estado del tema")
                        }
                    }
                }
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width > 100 {
                                withAnimation {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                )
            }
        }
        .background(Color.white)
    }
}

// Vista para el contenido de una sección
struct SectionContentView: View {
    let text: String
    let video: String
    let image: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Procesamiento del texto para identificar secciones especiales
            if !text.isEmpty {
                if text.contains("Key Takeaways:") {
                    let parts = text.components(separatedBy: "Key Takeaways:")
                    
                    // Texto principal
                    Text(parts[0].trimmingCharacters(in: .whitespacesAndNewlines))
                        .font(.body)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    // Sección de Key Takeaways
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Key Takeaways:")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.indigo)
                            .padding(.bottom, 8)
                        
                        // Procesar los elementos marcados con símbolos especiales
                        FormatKeyTakeaways(text: parts[1])
                    }
                    .padding(24)
                    .background(Color.indigo.opacity(0.05))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                } else {
                    // Contenido de texto normal
                    Text(text)
                        .font(.body)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                }
            }
            
            // Imagen si existe
            if !image.isEmpty {
                AsyncImage(url: URL(string: image)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12)
                    } else if phase.error != nil {
                        Text("Error loading image")
                            .foregroundColor(.red)
                    } else {
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
            }
            
            // Video si existe
            if !video.isEmpty {
                Video(url: video, autoplay: 1)
                    .frame(height: 220)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
            }
        }
    }
}

struct FormatKeyTakeaways: View {
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(parseKeyTakeaways(from: text), id: \.self) { item in
                if let number = item.number {
                    HStack(alignment: .top, spacing: 12) {
                        // Círculo con número
                        ZStack {
                            Circle()
                                .fill(Color.indigo)
                                .frame(width: 24, height: 24)
                            
                            Text("\(number)")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        Text(item.text)
                            .font(.body)
                            .foregroundColor(.black)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(4)
                    }
                } else {
                    Text(item.text)
                        .font(.body)
                        .foregroundColor(.black)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(4)
                }
            }
        }
    }
    
    struct KeyTakeawayItem: Hashable {
        let number: Int?
        let text: String
    }
    
    func parseKeyTakeaways(from text: String) -> [KeyTakeawayItem] {
        var items: [KeyTakeawayItem] = []
        
        // Dividir el texto en secciones basado en los prefijos especiales
        let textToProcess = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Extraer items específicos usando patrones específicos
        let pattern1 = "\\n\\n\\*" // Patrón para el punto 1: "\n\n*"
        let pattern2 = "\\n\\*\\*" // Patrón para el punto 2: "\n**"
        let pattern3 = "\\n@"     // Patrón para el punto 3: "\n@"
        
        // Buscar todos los patrones en el texto
        let scanner = Scanner(string: textToProcess)
        var remainingText = textToProcess
        
        // Buscar el patrón 1 (punto 1) - "\n\n*"
        if let range = remainingText.range(of: pattern1) {
            let startIndex = range.upperBound
            
            // Buscar el final de esta sección (el inicio de otro patrón o final del texto)
            var endIndex: String.Index
            if let range2 = remainingText.range(of: pattern2, range: startIndex..<remainingText.endIndex) {
                endIndex = range2.lowerBound
            } else if let range3 = remainingText.range(of: pattern3, range: startIndex..<remainingText.endIndex) {
                endIndex = range3.lowerBound
            } else {
                endIndex = remainingText.endIndex
            }
            
            let content = String(remainingText[startIndex..<endIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !content.isEmpty {
                items.append(KeyTakeawayItem(number: 1, text: content))
            }
        }
        
        // Buscar el patrón 2 (punto 2) - "\n**"
        if let range = remainingText.range(of: pattern2) {
            let startIndex = range.upperBound
            
            // Buscar el final de esta sección
            var endIndex: String.Index
            if let range3 = remainingText.range(of: pattern3, range: startIndex..<remainingText.endIndex) {
                endIndex = range3.lowerBound
            } else {
                endIndex = remainingText.endIndex
            }
            
            let content = String(remainingText[startIndex..<endIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !content.isEmpty {
                items.append(KeyTakeawayItem(number: 2, text: content))
            }
        }
        
        // Buscar el patrón 3 (punto 3) - "\n@"
        if let range = remainingText.range(of: pattern3) {
            let startIndex = range.upperBound
            let content = String(remainingText[startIndex..<remainingText.endIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !content.isEmpty {
                items.append(KeyTakeawayItem(number: 3, text: content))
            }
        }
        
        // Si no encontramos puntos con los patrones específicos, intentamos el enfoque clásico
        if items.isEmpty {
            // Dividir por saltos de línea
            let lines = textToProcess.split(separator: "\n").map { String($0).trimmingCharacters(in: .whitespaces) }
            
            for line in lines {
                if line.isEmpty || line.hasPrefix("Key Takeaways") { continue }
                
                if line.hasPrefix("*") && !line.hasPrefix("**") {
                    let cleanLine = line.dropFirst().trimmingCharacters(in: .whitespaces)
                    items.append(KeyTakeawayItem(number: 1, text: cleanLine))
                } else if line.hasPrefix("**") {
                    let cleanLine = line.dropFirst(2).trimmingCharacters(in: .whitespaces)
                    items.append(KeyTakeawayItem(number: 2, text: cleanLine))
                } else if line.hasPrefix("@") {
                    let cleanLine = line.dropFirst().trimmingCharacters(in: .whitespaces)
                    items.append(KeyTakeawayItem(number: 3, text: cleanLine))
                }
            }
        }
        
        return items
    }
}

struct Video: UIViewRepresentable {
    let url: String
    let id: String
    let autoplay: Int
    
    init(url: String, autoplay: Int) {
        self.url = url
        self.autoplay = autoplay
        self.id = Video.extractYTVideoID(from: url) ?? ""
    }
    
    // Función estática para extraer el ID del video
    static func extractYTVideoID(from youtubeURL: String) -> String? {
        // Patrones para URLs de YouTube:
        // 1. youtube.com/watch?v=VIDEO_ID
        // 2. youtu.be/VIDEO_ID
        // 3. youtube.com/embed/VIDEO_ID
        
        if let url = URL(string: youtubeURL) {
            // Patrón 1: youtube.com/watch?v=VIDEO_ID
            if url.host?.contains("youtube.com") == true {
                if let queryItems = URLComponents(string: youtubeURL)?.queryItems {
                    for item in queryItems where item.name == "v" {
                        return item.value
                    }
                }
                
                // Patrón 3: youtube.com/embed/VIDEO_ID
                if url.path.contains("/embed/") {
                    let components = url.path.components(separatedBy: "/embed/")
                    if components.count > 1 {
                        return components[1]
                    }
                }
            }
            
            // Patrón 2: youtu.be/VIDEO_ID
            if url.host == "youtu.be" {
                return String(url.path.dropFirst())  // Convert Substring to String
            }
        }
        
        return nil
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
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
        self.id = Video.extractYTVideoID(from: url) ?? ""
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
    // Delegamos a la función estática para evitar duplicar código
    return Video.extractYTVideoID(from: url)
}

struct Sections_Previews: PreviewProvider {
 static var previews: some View {
 SectionsView(topicID: 1, topicTitle: "Titulo del topico", user: 1, isChecked: false)
 }
 }
 
