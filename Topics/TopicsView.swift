import SwiftUI
import Foundation
import Combine

struct TopicsView: View {
    let contentID: Int
    let contentTitle: String
    @State var contentDescription: String = "Aprende y estudia a tu ritmo"
    let user: Int
    let contentImageURL: String
    @State private var showMenu = false
    @StateObject var TopicsVM: TopicsViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoading = true
    @State private var messageLoad = "Cargando..."
    @State private var overallProgress: Double = 0.65 // Progreso general (se puede calcular basado en temas completados)
    @State private var selectedLesson: TopicsModel? = nil
    @State private var selectedLessonUpdating: Int? = nil
    @State private var webViewPresented = false
    @State private var showingWebView = false
    
    // Inicializador que permite pasar un TopicsViewModel preconfigurado
    init(contentID: Int, contentTitle: String, user: Int, contentImageURL: String, TopicsVM: TopicsViewModel = TopicsViewModel()) {
        self.contentID = contentID
        self.contentTitle = contentTitle
        self.user = user
        self.contentImageURL = contentImageURL
        
        // Detectar si estamos en preview
        let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        
        // Si no estamos en preview, usar un ViewModel limpio
        if !isPreview {
            self._TopicsVM = StateObject(wrappedValue: TopicsViewModel())
        } else {
            // En preview, usar el ViewModel proporcionado
            self._TopicsVM = StateObject(wrappedValue: TopicsVM)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            topicsContent(geometry: geometry)
        }
        .background(Color.white)
    }
    
    // Extraer el contenido principal a una función para reducir la complejidad
    private func topicsContent(geometry: GeometryProxy) -> some View {
            NavigationStack {
            ZStack(alignment: .top) {
                // Fondo general
                Color.white.edgesIgnoringSafeArea(.all)
                
                // Botón de regreso como overlay
                backButtonOverlay
                
                // Contenido principal
                mainContentStack(geometry: geometry)
            }
            .onAppear {
                loadData()
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        }
    }
    
    // Botón de regreso
    private var backButtonOverlay: some View {
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
                .padding(.top, 0) // Ajustado para la nueva altura del header
                        .padding(.leading, 20)
                        
                        Spacer()
            }
            Spacer()
        }
        .zIndex(100) // Asegurar que esté por encima de otros elementos
    }
    
    // Contenido principal
    private func mainContentStack(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // Header con imagen
            headerView
            
            // Contenido scrollable
            contentScrollView(geometry: geometry)
        }
        .edgesIgnoringSafeArea(.top) // Ignorar safe area en la parte superior para la imagen
    }
    
    // Vista del encabezado
    private var headerView: some View {
        ZStack(alignment: .bottom) {
            // Contenedor de base con color de fondo que siempre está presente
            Rectangle()
                .foregroundColor(Color(.systemGray5))
                .frame(height: 250)
                .edgesIgnoringSafeArea(.top)
            
            // Imagen de fondo o placeholder
            Group {
                // Usar la imagen del contenido si está disponible
                if !contentImageURL.isEmpty {
                    let processedURL = APIClient.getFullImageURL(contentImageURL)
                    
                    // Primero intentar con la URL normal
                    if let url = URL(string: processedURL) {
                        headerImageView(url: url)
                    }
                    // Si falla, intentar con URL codificada
                    else if let escapedURL = processedURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                            let url = URL(string: escapedURL) {
                        headerImageView(url: url)
                            .onAppear {
                                print("Header using escaped URL: \(escapedURL)")
                            }
                    }
                    // Si ambos fallan, mostrar error
                    else {
                        // URL inválida
                        Rectangle()
                            .foregroundColor(Color(.systemGray5))
                            .overlay(placeholderImage)
                            .frame(height: 250)
                            .edgesIgnoringSafeArea(.top)
                            .onAppear {
                                print("Invalid content image URL even after escaping: \(processedURL)")
                            }
                    }
                } else {
                    // Si no hay imagen de contenido, mostrar placeholder
                    Rectangle()
                        .foregroundColor(Color(.systemGray5))
                        .overlay(placeholderImage)
                        .frame(height: 250)
                        .edgesIgnoringSafeArea(.top)
                        .onAppear {
                            print("No content image available")
                        }
                }
            }
            
            // Overlay de gradiente oscuro para legibilidad del texto
            LinearGradient(
                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 250)
            .edgesIgnoringSafeArea(.top)
            
            // Título y descripción en la parte inferior
            VStack(alignment: .leading, spacing: 5) {
                Text(contentTitle)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(contentDescription)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(height: 250)
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
                        .frame(width: geo.size.width, height: 250)
                        .clipped()
                        .edgesIgnoringSafeArea(.top)
                } else if phase.error != nil {
                    // Si hay error al cargar, mostrar placeholder e imprimir error
                    Rectangle()
                        .foregroundColor(Color(.systemGray5))
                        .overlay(placeholderImage)
                        .frame(height: 250)
                        .onAppear {
                            print("Error loading content image: \(url)")
                            print("Error details: \(String(describing: phase.error))")
                        }
                } else {
                    // Mientras carga
                    Rectangle()
                        .foregroundColor(Color(.systemGray5))
                        .overlay(ProgressView())
                        .frame(height: 250)
                }
            }
            .onAppear {
                print("Attempting to load header image from URL: \(url)")
            }
        }
        .frame(height: 250)
    }
    
    // Imagen placeholder reutilizable
    private var placeholderImage: some View {
        Image(systemName: "photo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 40, height: 40)
            .foregroundColor(.gray)
    }
    
    // Contenido scrollable
    private func contentScrollView(geometry: GeometryProxy) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Sección de progreso
                progressSection
                
                // Sección de lecciones
                lessonsSection(geometry: geometry)
            }
        }
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
    
    // Sección de progreso
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Overall Progress")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(overallProgress * 100))%")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
            }
            .padding(.top, 20)
            
            // Barra de progreso
            TopicsProgressBar(progress: overallProgress)
                .frame(height: 8)
        }
        .padding(.horizontal, 20)
    }
    
    // Sección de lecciones
    private func lessonsSection(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Lessons")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.top, 25)
                .padding(.bottom, 20)
            
            if isLoading {
                loadingView(geometry: geometry)
            } else {
                lessonsList
            }
        }
        .padding(.horizontal, 16)
    }
    
    // Vista de carga
    private func loadingView(geometry: GeometryProxy) -> some View {
        VStack {
            if messageLoad == "Cargando..." {
                ProgressView(messageLoad)
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding(.top, 50)
            } else {
                Text(messageLoad)
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.top, 50)
            }
        }
        .frame(width: geometry.size.width - 40, height: 200)
    }
    
    // Lista de lecciones
    private var lessonsList: some View {
        VStack(spacing: 8) {
            ForEach(TopicsVM.resultTopics) { topic in
                NavigationLink(destination: SectionsView(
                    topicID: topic.topic,
                    topicTitle: topic.title,
                    user: user,
                    isChecked: topic.done ?? false,
                    thumbnail_url: topic.thumbnail_url,
                    contentTitle: contentTitle
                )) {
                    LessonRow(
                        number: topic.topic,
                        title: topic.title,
                        description: topic.description,
                        isChecked: topic.done ?? false,
                        user: user,
                        topicId: topic.topic,
                        thumbnail_url: topic.thumbnail_url
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 0)
    }
    
    // Función para cargar datos
    private func loadData() {
        // Siempre cargar datos frescos de la API en entorno real
        // Resetear el array de resultados para asegurar que se muestren datos frescos
        if (ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"].flatMap({ Bool($0) }) == nil) ?? false {
            // Solo en entorno real (no preview), resetear los datos y mostrar loading
            DispatchQueue.main.async {
                self.TopicsVM.resultTopics = []
                self.isLoading = true
                self.messageLoad = "Cargando..."
            }
        }
        
        Task {
            do {
                            try await TopicsVM.getTopics(contentIDVM: contentID, userIDVM: user)
                            
                            if TopicsVM.resultTopics.isEmpty {
                                messageLoad = "No hay datos"
                } else {
                    // Si hay al menos un tema, usar su descripción como descripción del contenido
                    if let firstTopic = TopicsVM.resultTopics.first {
                        contentDescription = firstTopic.description
                        
                        // Imprimir detalladamente la URL para depuración
                        print("--------- DETALLE DE IMÁGENES ---------")
                        for topic in TopicsVM.resultTopics {
                            print("Topic ID: \(topic.topic), Title: \(topic.title)")
                            print("Thumbnail URL original: \"\(topic.thumbnail_url)\"")
                            print("URL contains facebook? \(topic.thumbnail_url.contains("facebook"))")
                            print("URL contains fbcdn? \(topic.thumbnail_url.contains("fbcdn"))")
                            
                            let processedURL = APIClient.getFullImageURL(topic.thumbnail_url)
                            print("Processed URL: \(processedURL)")
                            
                            if let url = URL(string: processedURL) {
                                print("Valid URL created: \(url)")
                            } else {
                                print("⚠️ ERROR: Could not create URL from string")
                                
                                // Intentar escapar la URL
                                if let escapedURL = processedURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                   let url = URL(string: escapedURL) {
                                    print("After escaping, valid URL created: \(url)")
                                } else {
                                    print("⚠️ ERROR: Even with escaping, could not create URL")
                                }
                            }
                            print("---------------------------------")
                        }
                    }
                }
                isLoading = TopicsVM.resultTopics.isEmpty
                
                // Calcular el progreso general basado en temas completados
                if !TopicsVM.resultTopics.isEmpty {
                    let completedTopics = TopicsVM.resultTopics.filter { $0.done == true }.count
                    overallProgress = Double(completedTopics) / Double(TopicsVM.resultTopics.count)
                }
            } catch {
                print("Error fetching topics: \(error)")
                // En caso de error, actualizar UI
                DispatchQueue.main.async {
                    self.messageLoad = "Error cargando datos"
                    self.isLoading = true
                }
            }
        }
    }
    
    // Función auxiliar para actualizar la UI cuando ya hay datos
    private func updateUIFromExistingData() {
        if let firstTopic = TopicsVM.resultTopics.first {
            contentDescription = firstTopic.description
            print("Preview thumbnail URL: \(firstTopic.thumbnail_url)")
        }
        
        isLoading = false
        
        // Calcular el progreso basado en temas completados
        let completedTopics = TopicsVM.resultTopics.filter { $0.done == true }.count
        overallProgress = TopicsVM.resultTopics.isEmpty ? 0 : Double(completedTopics) / Double(TopicsVM.resultTopics.count)
    }
}

// Componente para una fila de lección
struct LessonRow: View {
    let number: Int
    let title: String
    let description: String
    let isChecked: Bool
    let user: Int
    let topicId: Int
    var thumbnail_url: String = ""
    
    var body: some View {
        HStack(spacing: 0) {
            // Parte izquierda - imagen del tema o placeholder
            ZStack {
                // Fondo gris claro siempre presente
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 90, height: 90)
                    .cornerRadius(12)
                
                // Imagen del tema
                Group {
                    if !thumbnail_url.isEmpty {
                        let processedURL = APIClient.getFullImageURL(thumbnail_url)
                        
                        if let url = URL(string: processedURL) {
                            loadImageFromURL(url)
                        } else if let escapedURL = processedURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                let url = URL(string: escapedURL) {
                            loadImageFromURL(url)
                                .onAppear {
                                    print("LessonRow using escaped URL: \(escapedURL)")
                                }
                        } else {
                            lessonPlaceholder
                                .onAppear {
                                    print("Invalid thumbnail URL in LessonRow: \(processedURL)")
                                }
                        }
                    } else {
                        lessonPlaceholder
                    }
                }
            }
            .frame(width: 90, height: 90)
            
            // Parte derecha - contenido con número, título y descripción
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 10) {
                        // Círculo con número
                        ZStack {
                            Circle()
                                .fill(isChecked ? Color.green : Color.indigo)
                                .frame(width: 28, height: 28)
                            
                            if isChecked {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            } else {
                                Text("\(number)")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                .padding(.leading, 15)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
                    .padding(.trailing, 15)
            }
        }
        .frame(height: 90)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isChecked ? Color.green.opacity(0.3) : Color.gray.opacity(0.1), lineWidth: isChecked ? 2 : 1)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
    }
    
    // Helper function to load images
    @ViewBuilder
    private func loadImageFromURL(_ url: URL) -> some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 90, height: 90)
                .cornerRadius(12)
                .clipped()
        } placeholder: {
            ProgressView()
        }
        .onAppear {
            print("Loading lesson image from URL: \(url)")
        }
    }
    
    private var lessonPlaceholder: some View {
        Image(systemName: "book.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .foregroundColor(.gray)
    }
}
// Renombramos el componente ProgressBar
struct TopicsProgressBar: View {
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

// Crear un archivo separado para los datos de preview
struct TopicsPreviewData {
    static let sampleTopics = [
        TopicsModel(
            done: true, topic: 1,
            title: "Introducción a la Ansiedad",
            description: "Conceptos básicos sobre la ansiedad",
            content: 1,
            thumbnail_url: "https://images.pexels.com/photos/33109/fall-autumn-red-season.jpg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2"
        ),
        TopicsModel(
            done: false, topic: 2,
            title: "Técnicas de Respiración",
            description: "Aprende ejercicios de respiración",
            content: 1,
            thumbnail_url: "https://images.pexels.com/photos/417074/pexels-photo-417074.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2"
        )
    ]
}

struct Topics_Previews: PreviewProvider {
    static var previews: some View {
        // Creamos un ViewModel con datos para preview
        let previewVM = TopicsViewModel()
        previewVM.resultTopics = TopicsPreviewData.sampleTopics
        
        return TopicsView(
            contentID: 1,
            contentTitle: "Introducción",
            user: 1,
            contentImageURL: "https://images.pexels.com/photos/33109/fall-autumn-red-season.jpg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
            TopicsVM: previewVM
        )
    }
}
