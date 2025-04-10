import SwiftUI
import WebKit

struct SectionsView: View {
    @Environment(\.managedObjectContext) var moc
    let topicID : Int
    let topicTitle: String
    let user: Int
    let isChecked: Bool
    let thumbnail_url: String
    let contentTitle: String?
    @Binding var shouldRefresh: Bool
    @State private var progress: Float = 0.6
    @State private var showMenu = false
    @StateObject var SectionsVM = SectionsViewModel()
    @StateObject var TopicsVM = TopicsViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoading = true
    @State private var messageLoad = "Cargando..."
    @State private var checkButton = false
    @State private var exist = false
    @State private var mainContentTitle: String = "Understanding Anxiety" // Default value
    
    init(topicID: Int, topicTitle: String, user: Int, isChecked: Bool, thumbnail_url: String, contentTitle: String? = nil, shouldRefresh: Binding<Bool>) {
        self.topicID = topicID
        self.topicTitle = topicTitle
        self.user = user
        self.isChecked = isChecked
        self.thumbnail_url = thumbnail_url
        self.contentTitle = contentTitle
        self._shouldRefresh = shouldRefresh
        
        if let title = contentTitle {
            self._mainContentTitle = State(initialValue: title)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack(alignment: .top) {
                    // Fondo general
                    Color.white.edgesIgnoringSafeArea(.all)
                    
                    // Contenido principal
                    VStack(spacing: 0) {
                        // Header con imagen - extendido hasta arriba
                        headerView
                        
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
                                        // Marcar que se debe actualizar la vista de contenido
                                        shouldRefresh = true
                                        print("🔄 Tema marcado como \(checkButton ? "completado" : "pendiente"), solicitando actualización")
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
                            .background(Color.white)
                            .padding(.top, -1) // Solapar ligeramente para eliminar línea
                            .clipShape(Rectangle())
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
                            print("Error fetching sections: \(error)")
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
                .onDisappear {
                    // Asegurarse de que al desaparecer se dispare la actualización
                    if shouldRefresh {
                        print("🔄 SectionsView desapareciendo, shouldRefresh=\(shouldRefresh)")
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
    
    // Header con imagen - extendido hasta arriba
    var headerView: some View {
        ZStack(alignment: .bottomLeading) {
            // Imagen de fondo, se asegura de ocupar todo el espacio disponible sin margen
            if !thumbnail_url.isEmpty {
                let processedURL = APIClient.getFullImageURL(thumbnail_url)
                
                if let url = URL(string: processedURL) {
                    headerImageView(url: url)
                } else if let escapedURL = processedURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                          let url = URL(string: escapedURL) {
                    headerImageView(url: url)
                        .onAppear {
                            print("SectionsView header using escaped URL: \(escapedURL)")
                        }
                } else {
                    // Solo si no hay URL válida, mostrar un placeholder
                    Color.clear
                        .frame(height: 300)
                        .edgesIgnoringSafeArea(.all)
                        .overlay(
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                        )
                        .onAppear {
                            print("Invalid URL in SectionsView header: \(processedURL)")
                        }
                }
            } else {
                // Fondo transparente si no hay imagen
                Color.clear
                    .frame(height: 300)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                    )
            }
            
            // Gradiente superpuesto solo para oscurecer la parte inferior y mejorar la legibilidad del texto
            LinearGradient(
                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.5)]), // Reducir la opacidad del gradiente
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            // Títulos superpuestos, moviéndolos hacia abajo
            VStack(alignment: .leading, spacing: 6) {
                Spacer().frame(height: 200) // Mover los títulos más abajo

                // Título del curso principal con sombra para mejor contraste
                Text(mainContentTitle)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.7), radius: 3, x: 0, y: 1)
                
                // Título de la sección actual con sombra para mejor contraste
                Text(topicTitle)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.7), radius: 3, x: 0, y: 1)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .zIndex(2) // Asegurar que el texto esté por encima de todas las capas
        }
        .frame(height: 200)  // Asegúrate de que el frame sea adecuado
        .edgesIgnoringSafeArea(.all)
        .background(Color.clear) // Cambié de Color.black a Color.clear para eliminar el fondo negro
    }

    
    // Helper to create header image view
    @ViewBuilder
    private func headerImageView(url: URL) -> some View {
        GeometryReader { geo in
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: 300)
                        .clipped()
                } else if phase.error != nil {
                    // En caso de error, usar un fondo negro en lugar de transparente o gris
                    Color.black
                        .overlay(
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                        )
                        .onAppear {
                            print("Error loading header image: \(url)")
                            print("Error details: \(String(describing: phase.error))")
                        }
                } else {
                    // Mientras carga, mostrar fondo negro
                    Color.black
                        .overlay(ProgressView().foregroundColor(.white))
                }
            }
            .onAppear {
                print("Attempting to load SectionsView header image from URL: \(url)")
            }
        }
        .frame(height: 300)
        .edgesIgnoringSafeArea(.all)
        .clipShape(Rectangle())
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
                    
                    // Texto principal con mejor estilo para contraste
                    Text(parts[0].trimmingCharacters(in: .whitespacesAndNewlines))
                        .font(.body)
                        .fontWeight(.medium) // Aumentado de regular a medium para mejor contraste
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
                    .padding(.bottom, 20) // Añadido padding adicional abajo
                    
                    // Espacio adicional después de Key Takeaways
                    Spacer().frame(height: 10)
                } else {
                    // Contenido de texto normal con mejor estilo para contraste
                    Text(text)
                        .font(.body)
                        .fontWeight(.medium) // Aumentado de regular a medium para mejor contraste
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                }
            }
            
            // Video si existe
            if !video.isEmpty {
                // Añadimos un espacio adicional antes del video cuando hay key takeaways
                if text.contains("Key Takeaways:") {
                    Spacer()
                        .frame(height: 20)
                }
                
                Video(url: video, autoplay: 1)
                    .frame(height: 220)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
            }
            
            // Espacio entre el video y la imagen si ambos existen
            if !video.isEmpty && !image.isEmpty {
                Spacer()
                    .frame(height: 30)
            }
            
            // Imagen si existe
            if !image.isEmpty {
                VStack(spacing: 8) {
                    // Si hay texto antes de la imagen, asegurarse de que tenga buen contraste
                    if !text.isEmpty && video.isEmpty {
                        Divider()
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)
                    }
                    
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
        
        // Primero limpiamos el texto para trabajar con él
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Dividir el texto en líneas usando el formato \\n
        let lines = cleanText.components(separatedBy: "\\n")
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Ignorar líneas vacías y el título "Key Takeaways:"
            if trimmedLine.isEmpty || trimmedLine == "Key Takeaways:" {
                continue
            }
            
            // Identificar el tipo de punto según los prefijos (* para 1, ** para 2, @ para 3)
            if trimmedLine.hasPrefix("*") && !trimmedLine.hasPrefix("**") {
                // Primer punto (*)
                let content = trimmedLine.dropFirst().trimmingCharacters(in: .whitespacesAndNewlines)
                items.append(KeyTakeawayItem(number: 1, text: content))
            } else if trimmedLine.hasPrefix("**") {
                // Segundo punto (**)
                let content = trimmedLine.dropFirst(2).trimmingCharacters(in: .whitespacesAndNewlines)
                items.append(KeyTakeawayItem(number: 2, text: content))
            } else if trimmedLine.hasPrefix("@") {
                // Tercer punto (@)
                let content = trimmedLine.dropFirst().trimmingCharacters(in: .whitespacesAndNewlines)
                items.append(KeyTakeawayItem(number: 3, text: content))
            } else if !trimmedLine.isEmpty {
                // Texto normal (sin número)
                items.append(KeyTakeawayItem(number: nil, text: trimmedLine))
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
 SectionsView(topicID: 1, topicTitle: "Titulo del topico", user: 1, isChecked: false, thumbnail_url: "", contentTitle: nil, shouldRefresh: .constant(false))
 }
 }
 
