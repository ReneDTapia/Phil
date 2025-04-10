import Foundation
import Combine
import Alamofire

class ChatViewModel: ObservableObject {
    
    @Published var conversations: [Conversation] = []
    @Published var messages: [Message] = []
    @Published var newConversationId: Int?
    @Published var currentThreadId: String?
    
    // ID del asistente de OpenAI (reemplazar con el ID real)
    private let assistantId = "asst_zjqrUTBWpkf47QWfFRXxDS2R"
    
    init() {
        // Verificar y registrar información sobre la API key
        OpenAIAPIKey.logInfo()
        
        if !OpenAIAPIKey.isValid() {
            print("ADVERTENCIA: La API key de OpenAI no parece válida. Las funciones del asistente podrían no funcionar.")
        }
    }
    
    // Utiliza APIClient para obtener las conversaciones jajajaj de nada papus
    func fetchConversations(userId: Int) async {
        do {
            let fetchedConversations: [Conversation] = try await APIClient.get(path: "getUserConversations/\(userId)")
            DispatchQueue.main.async { [weak self] in
                self?.conversations = fetchedConversations
            }
        } catch {
            print("Error fetching conversations: \(error.localizedDescription)")
        }
    }

    // Utiliza APIClient para obtener los mensajes siuuu:v
    func fetchMessages(conversationId: Int) {
        print("Obteniendo mensajes para conversationId: \(conversationId)")
        
        // Primero intentamos obtener la información de la conversación del listado de conversaciones
        if conversations.isEmpty {
            print("No hay conversaciones cargadas en memoria. Cargando todas las conversaciones primero...")
            
            // Obtenemos el userId del token almacenado
            let userId = TokenHelper.getUserID() ?? 6
            print("Usando usuario ID: \(userId) para obtener conversaciones")
            
            // Si no tenemos las conversaciones cargadas, las cargamos primero
            Task {
                await fetchConversationsAndThenMessages(userId: userId, conversationId: conversationId)
            }
        } else {
            print("Conversaciones ya cargadas en memoria. Buscando la conversación #\(conversationId)")
            // Si ya tenemos las conversaciones cargadas, intentamos encontrar la conversación por id
            if let conversation = conversations.first(where: { $0.id == conversationId }) {
                print("Conversación #\(conversationId) encontrada en memoria con nombre: \(conversation.name)")
                // Extraer el thread_id si existe
                if let threadId = conversation.threadId, !threadId.isEmpty {
                    print("Thread ID encontrado: \(threadId)")
                    self.currentThreadId = threadId
                } else {
                    print("La conversación no tiene thread_id asignado")
                }
                
                // Ahora obtenemos los mensajes
                fetchOnlyMessages(conversationId: conversationId)
            } else {
                print("La conversación #\(conversationId) no se encontró en la lista de conversaciones")
                // Si no encontramos la conversación, cargamos todas las conversaciones nuevamente
                let userId = TokenHelper.getUserID() ?? 6
                Task {
                    await fetchConversationsAndThenMessages(userId: userId, conversationId: conversationId)
                }
            }
        }
    }
    
    // Función para cargar primero todas las conversaciones y luego los mensajes
    private func fetchConversationsAndThenMessages(userId: Int, conversationId: Int) async {
        print("Obteniendo lista completa de conversaciones para user #\(userId)")
        
        do {
            // Obtener directamente la conversación completa desde el endpoint getUserConversations
            let fetchedConversations: [Conversation] = try await APIClient.get(path: "getUserConversations/\(userId)")
            
            // Actualizamos la lista completa de conversaciones
            DispatchQueue.main.async {
                self.conversations = fetchedConversations
            }
            
            // Imprimimos todas las conversaciones para depuración
            print("✅ Se obtuvieron \(fetchedConversations.count) conversaciones")
            
            // Buscamos específicamente la conversación que necesitamos
            if let conversation = fetchedConversations.first(where: { $0.id == conversationId }) {
                print("✅ Conversación #\(conversationId) encontrada con nombre: \(conversation.name)")
                
                // Extraer el thread_id si existe
                if let threadId = conversation.threadId, !threadId.isEmpty {
                    print("✅ Thread ID encontrado: \(threadId)")
                    DispatchQueue.main.async {
                        self.currentThreadId = threadId
                    }
                } else {
                    print("⚠️ La conversación no tiene thread_id asignado")
                    // Aquí podríamos implementar la creación de un nuevo thread_id
                }
            } else {
                print("❌ No se encontró la conversación #\(conversationId) en la lista del usuario #\(userId)")
            }
            
            // Finalmente obtenemos los mensajes
            fetchOnlyMessages(conversationId: conversationId)
            
        } catch {
            print("❌ Error al obtener las conversaciones: \(error.localizedDescription)")
            // Intentar obtener solo los mensajes como fallback
            fetchOnlyMessages(conversationId: conversationId)
        }
    }
    
    // Función que solo obtiene los mensajes sin intentar obtener el thread_id
    func fetchOnlyMessages(conversationId: Int) {
        print("Obteniendo solo los mensajes para conversación #\(conversationId)")
        APIClient.getN(path: "getConversation/\(conversationId)") { [weak self] (result: Result<[Message], AFError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let messages):
                    self?.messages = messages
                    print("✅ \(messages.count) mensajes cargados para la conversación #\(conversationId)")
                case .failure(let error):
                    print("❌ Error obteniendo mensajes: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Obtener el thread_id para una conversación específica
    private func getThreadIdForConversation(conversationId: Int) {
        print("Buscando threadId para la conversación #\(conversationId)")
        
        // Primero verificamos si la conversación está en memoria
        if let conversation = conversations.first(where: { $0.id == conversationId }) {
            print("Conversación encontrada en memoria")
            print("Detalles de la conversación: id=\(conversation.id), name=\(conversation.name), threadId=\(conversation.threadId ?? "null")")
            
            if let threadId = conversation.threadId, !threadId.isEmpty {
                print("ThreadId encontrado en memoria: \(threadId)")
                self.currentThreadId = threadId
            } else {
                print("La conversación existe en memoria pero no tiene threadId")
            }
            return
        }
        
        // Si no encontramos la conversación en memoria, la buscamos en la API
        print("Conversación no encontrada en memoria, consultando a la API...")
        
        // Primero, intentar obtener la información de la conversación desde el endpoint específico
        APIClient.getN(path: "getConversation/\(conversationId)/info") { [weak self] (result: Result<Conversation, AFError>) in
            switch result {
            case .success(let conversation):
                print("Conversación obtenida de la API - Detalles completos:")
                print("ID: \(conversation.id)")
                print("Nombre: \(conversation.name)")
                print("Último mensaje: \(conversation.lastMessageAt ?? "N/A")")
                print("ThreadId (raw): \(conversation.threadId ?? "null")")
                
                if let threadId = conversation.threadId, !threadId.isEmpty {
                    print("ThreadId obtenido de la API: \(threadId)")
                    DispatchQueue.main.async {
                        self?.currentThreadId = threadId
                    }
                } else {
                    print("⚠️ La conversación existe en la API pero no tiene threadId")
                }
            case .failure(let error):
                print("Error al obtener información de la conversación: \(error.localizedDescription)")
                if let underlyingError = error.underlyingError {
                    print("Error subyacente: \(underlyingError)")
                }
                
                // En lugar de intentar acceder a responseData (que no existe en AFError)
                // solo registramos el error
                print("Intentando método alternativo para obtener el threadId...")
                
                // Como fallback, intentamos obtener el threadId de alguna otra manera
                self?.tryAlternativeThreadIdRetrieval(conversationId: conversationId)
            }
        }
    }
    
    // Método alternativo para intentar obtener el threadId si el método principal falla
    private func tryAlternativeThreadIdRetrieval(conversationId: Int) {
        print("Intentando método alternativo para obtener el thread_id para la conversación #\(conversationId)")
        
        // Alternativa 1: Intentar con endpoint diferente
        APIClient.getN(path: "conversation/\(conversationId)") { [weak self] (result: Result<ConversationDetails, AFError>) in
            switch result {
            case .success(let details):
                print("Detalles de conversación obtenidos usando endpoint alternativo")
                if let threadId = details.thread_id, !threadId.isEmpty {
                    print("ThreadId alternativo encontrado: \(threadId)")
                    DispatchQueue.main.async {
                        self?.currentThreadId = threadId
                    }
                } else {
                    // Alternativa 2: Obtener todos los mensajes e intentar extraer el thread_id de ahí
                    self?.fetchAllMessagesForThreadId(conversationId: conversationId)
                }
            case .failure(let error):
                print("Error intentando alternativa 1: \(error.localizedDescription)")
                // Pasamos a alternativa 2: Obtener todos los mensajes
                self?.fetchAllMessagesForThreadId(conversationId: conversationId)
            }
        }
    }
    
    // Intenta obtener el thread_id consultando todos los mensajes de la conversación
    private func fetchAllMessagesForThreadId(conversationId: Int) {
        print("Intentando obtener thread_id de los mensajes de la conversación #\(conversationId)")
        
        APIClient.getN(path: "conversation/\(conversationId)/messages") { [weak self] (result: Result<[MessageWithDetails], AFError>) in
            switch result {
            case .success(let messages):
                if let message = messages.first(where: { $0.thread_id != nil && !$0.thread_id!.isEmpty }) {
                    print("ThreadId encontrado en mensaje: \(message.thread_id!)")
                    DispatchQueue.main.async {
                        self?.currentThreadId = message.thread_id
                    }
                } else {
                    print("No se encontró thread_id en ningún mensaje - Se creará uno nuevo la próxima vez")
                }
            case .failure(let error):
                print("Error intentando alternativa 2: \(error.localizedDescription)")
                print("No se pudo obtener el thread_id - Se creará uno nuevo cuando sea necesario")
            }
        }
    }
    
    // Crear un nuevo thread en OpenAI
    func createOpenAIThread() async -> String? {
        do {
            // Hacer la petición a la API de OpenAI para crear un nuevo thread
            let url = URL(string: "https://api.openai.com/v1/threads")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(OpenAIAPIKey.apiKey)", forHTTPHeaderField: "Authorization")
            // Añadir el encabezado requerido para la API de Assistants
            request.addValue("assistants=v2", forHTTPHeaderField: "OpenAI-Beta")
            
            // Usar async/await en lugar de completion handler
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, 
                  httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
                if let responseData = String(data: data, encoding: .utf8) {
                    print("Error response from OpenAI: \(responseData)")
                }
                print("HTTP Error: \(response)")
                return nil
            }
            
            let decoder = JSONDecoder()
            let threadResponse = try decoder.decode(OpenAIThreadResponse.self, from: data)
            self.currentThreadId = threadResponse.id
            print("Thread created successfully with ID: \(threadResponse.id)")
            return threadResponse.id
            
        } catch {
            print("Error creating OpenAI thread: \(error)")
            return nil
        }
    }
    
    func registerConversationWithAlamofire(name: String, userId: Int) async -> Int? {
        // Primero creamos un thread en OpenAI
        print("Creando nuevo thread en OpenAI...")
        let threadId = await createOpenAIThread()
        
        if let threadId = threadId {
            print("Thread creado exitosamente con ID: \(threadId)")
        } else {
            print("Error al crear el thread en OpenAI")
        }
        
        // Preparar parámetros para la API
        let parameters: Parameters = [
            "name": name,
            "userId": userId,
            "thread_id": threadId ?? ""
        ]
        
        print("Registrando conversación con parámetros: \(parameters)")

        do {
            let data: Data? = try await APIClient.post(path: "addConversation", parameters: parameters)
            if let data = data {
                print("Datos recibidos de la API: \(String(data: data, encoding: .utf8) ?? "No se pueden mostrar")")
                let conversationResponse = try JSONDecoder().decode(ConversationResponse.self, from: data)
                
                // Obtener el ID de la conversación
                let conversationId = conversationResponse.conversationId ?? conversationResponse.id
                
                if let conversationId = conversationId {
                    self.newConversationId = conversationId
                    self.currentThreadId = conversationResponse.threadId
                    
                    print("Conversación registrada exitosamente:")
                    print("- ID de conversación: \(conversationId)")
                    print("- Thread ID: \(conversationResponse.threadId ?? "No disponible")")
                    
                    return conversationId
                } else {
                    print("No se pudo obtener el ID de la conversación de la respuesta")
                    return nil
                }
            } else {
                print("No se recibieron datos al registrar la conversación")
                return nil
            }
        } catch {
            print("Error detallado al añadir conversación: \(error)")
            // Intenta imprimir más detalles sobre el error
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .dataCorrupted(let context):
                    print("Datos corruptos: \(context.debugDescription)")
                case .keyNotFound(let key, let context):
                    print("Clave no encontrada: \(key), contexto: \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("Tipo incorrecto: se esperaba \(type), contexto: \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("Valor no encontrado: se esperaba \(type), contexto: \(context.debugDescription)")
                @unknown default:
                    print("Error de decodificación desconocido")
                }
            }
            return nil
        }
    }
    
    func deleteConversation(conversationId: Int) async -> Bool {
        do {
            try await APIClient.delete(path: "deleteConversation/\(conversationId)")
            DispatchQueue.main.async { [weak self] in
                self?.conversations.removeAll { $0.id == conversationId }
            }
            return true
        } catch {
            print("Error deleting conversation: \(error.localizedDescription)")
            return false
        }
    }

    
    func updateConversationName(conversationId: Int, newName: String) async -> Bool {
        let parameters: Parameters = ["name": newName]

        do {
            let response: UpdateConversationResponse = try await APIClient.put(path: "updateConversationName/\(conversationId)", parameters: parameters)
            print(response.success)
            return true
        } catch {
            print("Error updating conversation name: \(error.localizedDescription)")
            return false
        }
    }
    
    // Función para cargar directamente la conversación completa con mensajes y thread_id
    func fetchFullConversation(conversationId: Int) async {
        print("Obteniendo conversación completa para conversationId: \(conversationId)")
        
        do {
            // Intentar obtener la conversación completa con mensajes y thread_id
            let fullConversation: ConversationWithMessages = try await APIClient.get(path: "getFullConversation/\(conversationId)")
            
            print("✅ Conversación completa obtenida con éxito")
            print("- ID: \(fullConversation.id)")
            print("- Nombre: \(fullConversation.name)")
            print("- Thread ID: \(fullConversation.thread_id ?? "No disponible")")
            print("- Mensajes: \(fullConversation.messages.count)")
            
            // Actualizar los mensajes
            DispatchQueue.main.async {
                self.messages = fullConversation.messages
            }
            
            // Actualizar el thread_id si existe
            if let threadId = fullConversation.thread_id, !threadId.isEmpty {
                print("✅ Thread ID encontrado en la conversación completa: \(threadId)")
                DispatchQueue.main.async {
                    self.currentThreadId = threadId
                }
            } else {
                print("⚠️ La conversación completa no tiene thread_id")
            }
            
        } catch {
            print("❌ Error al obtener la conversación completa: \(error.localizedDescription)")
            
            // Si falla, intentar el método tradicional
            fetchMessages(conversationId: conversationId)
        }
    }
    
    // Método para intentar varios endpoints hasta encontrar el threadId
    func findThreadIdByAnyMeans(conversationId: Int, userId: Int) async -> String? {
        print("🔍 Buscando thread_id para conversación #\(conversationId) usando todos los métodos disponibles")
        
        // Método 1: Verificar si ya tenemos el thread_id en memoria
        if let threadId = self.currentThreadId, !threadId.isEmpty {
            print("✅ Thread ID ya está en memoria: \(threadId)")
            return threadId
        }
        
        // Método 2: Buscar en la lista de conversaciones
        let convs = self.conversations
        if let conversation = convs.first(where: { $0.id == conversationId }),
           let threadId = conversation.threadId, !threadId.isEmpty {
            print("✅ Thread ID encontrado en lista de conversaciones: \(threadId)")
            self.currentThreadId = threadId
            return threadId
        }
        
        // Método 3: Obtener todas las conversaciones del usuario
        do {
            let fetchedConversations: [Conversation] = try await APIClient.get(path: "getUserConversations/\(userId)")
            
            if let conversation = fetchedConversations.first(where: { $0.id == conversationId }),
               let threadId = conversation.threadId, !threadId.isEmpty {
                print("✅ Thread ID encontrado en API getUserConversations: \(threadId)")
                DispatchQueue.main.async {
                    self.currentThreadId = threadId
                }
                return threadId
            }
        } catch {
            print("❌ Error obteniendo conversaciones: \(error.localizedDescription)")
        }
        
        // Método 4: Intentar obtener la conversación completa
        do {
            let fullConversation: ConversationWithMessages = try await APIClient.get(path: "getFullConversation/\(conversationId)")
            
            if let threadId = fullConversation.thread_id, !threadId.isEmpty {
                print("✅ Thread ID encontrado en getFullConversation: \(threadId)")
                DispatchQueue.main.async {
                    self.currentThreadId = threadId
                }
                return threadId
            }
        } catch {
            print("❌ Error obteniendo conversación completa: \(error.localizedDescription)")
        }
        
        // Si todo lo anterior falla, devolver null
        print("❌ No se encontró thread_id por ningún método")
        return nil
    }
}

// Estructuras para manejar respuestas de la API de OpenAI
struct OpenAIThreadResponse: Codable {
    let id: String
    let object: String
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case createdAt = "created_at"
    }
}

// Clase auxiliar para almacenar la API key de OpenAI
class OpenAIAPIKey {
    // Usar la API key proporcionada
    static let apiKey = ""
    
    // Método para verificar si la API key es válida
    static func isValid() -> Bool {
        return !apiKey.isEmpty && (apiKey.hasPrefix("sk-") || apiKey.hasPrefix("sk-proj-"))
    }
    
    // Método para imprimir información sobre la API key (sin mostrarla completa por seguridad)
    static func logInfo() {
        if isValid() {
            let prefix = String(apiKey.prefix(7))
            let suffix = String(apiKey.suffix(4))
            let maskLength = apiKey.count - 11
            let mask = String(repeating: "*", count: maskLength)
            print("API Key configurada: \(prefix)\(mask)\(suffix)")
            print("Longitud de la API Key: \(apiKey.count) caracteres")
        } else {
            print("API Key no válida o no configurada correctamente")
        }
    }
}
