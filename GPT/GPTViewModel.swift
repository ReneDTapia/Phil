//
//  GPTViewModel.swift
//  Phil
//
//  Created by Jesús Daniel Martínez García on 19/10/23.
//

import SwiftUI
import SwiftOpenAI
import Alamofire

final class GPTViewModel : ObservableObject {
    
    
    @Published var userForm : [UserForm] = []
    
    @Published var messages : [MessageChatGPT] = [
        .init(text: "Actúa como un psicologo llamado Phil y en todos mis mensajes ten en cuenta la siguiente informacion que te mandaré como contexto y si te pregunto algo con relación a lo siguiente ayudame a entenderlo como psicólogo. Si después de este mensaje te envio algo que no este relacionado con salud mental o psicología entonces contesta que solo me puedes responder preguntas de estos temas" , role: .system, hidden: true)
    ]
    
    @Published var currentMessage : MessageChatGPT = .init(text: "", role: .assistant)
    @Published var isProcessing: Bool = false
    @Published var currentThreadId: String?
    
    // ID del asistente de OpenAI
    private let assistantId = "asst_zjqrUTBWpkf47QWfFRXxDS2R"
    
    var openAI = SwiftOpenAI(apiKey: "")
    
    init() {
        // Verificar y registrar información sobre la API key
        if OpenAIAPIKey.isValid() {
            // Configurar SwiftOpenAI con la API key
            self.openAI = SwiftOpenAI(apiKey: OpenAIAPIKey.apiKey)
            print("SwiftOpenAI configurado con la API key")
        } else {
            print("ADVERTENCIA: La API key de OpenAI no parece válida. Las funciones de GPT podrían no funcionar.")
        }
    }
    
    ///Funcion SEND para usar con OpenAI Assistant API
    ///
    func send(message: String, isHidden: Bool = false, userContext: String, conversationId: Int, userId: Int) async {
        // Depurar el estado actual
        debugThreadId(conversationId: conversationId)
        
        // Verificar que tenemos un thread_id válido antes de continuar
        let threadIdValid = currentThreadId != nil && !currentThreadId!.isEmpty
        print("Thread ID disponible: \(threadIdValid ? "✅ Sí" : "❌ No")")
        
        // Si no tenemos un thread_id, intentamos obtenerlo pero NO creamos uno nuevo aquí
        // (la creación debe haberse manejado en GPTView.swift)
        if !threadIdValid {
            print("⚠️ No hay thread_id disponible para esta conversación.")
            print("Fallback: Usando SwiftOpenAI en lugar de Asistente")
            await sendUsingSwiftOpenAI(message: message, isHidden: isHidden, userContext: userContext, conversationId: conversationId, userId: userId)
            return
        }
        
        let threadId = currentThreadId!
        print("Usando threadId: \(threadId) para la conversación")
        
        await MainActor.run {
            self.isProcessing = true
            let userMessage = MessageChatGPT(text: message, role: .user, hidden: isHidden)
            self.messages.append(userMessage)
        }
        
        // Registra el mensaje del usuario en la base de datos
        registerMessageWithAlamofire(message: message, sentByUser: true, userId: userId, conversationId: conversationId)
        
        // 1. Añadimos el mensaje al thread
        let messageAdded = await addMessageToThread(threadId: threadId, message: message)
        if !messageAdded {
            print("❌ Error al añadir mensaje al thread. Intentando con SwiftOpenAI como fallback.")
            await sendUsingSwiftOpenAI(message: message, isHidden: isHidden, userContext: userContext, conversationId: conversationId, userId: userId)
            return
        }
        
        // 2. Creamos un run para procesar el mensaje con el asistente
        let runId = await createRun(threadId: threadId)
        
        if let runId = runId {
            print("✅ Run creado correctamente con ID: \(runId)")
            
            // 3. Esperamos a que el asistente termine de procesar
            let isCompleted = await waitForRunCompletion(threadId: threadId, runId: runId)
            
            if isCompleted {
                print("✅ Run completado correctamente")
                
                // 4. Obtenemos la respuesta del asistente
                let assistantResponses = await getThreadMessages(threadId: threadId)
                
                // Filtrar solo las respuestas del asistente y ordenarlas por más recientes
                let assistantOnlyResponses = assistantResponses.filter { $0.role == "assistant" }
                
                if let latestAssistantResponse = assistantOnlyResponses.first {
                    print("✅ Respuesta más reciente del asistente obtenida - creada en: \(latestAssistantResponse.createdAt)")
                    await MainActor.run {
                        self.currentMessage = MessageChatGPT(text: latestAssistantResponse.content, role: .assistant)
                        self.messages.append(self.currentMessage)
                        self.isProcessing = false
                    }
                    
                    // Registramos la respuesta del asistente en la base de datos
                    registerMessageWithAlamofire(
                        message: latestAssistantResponse.content,
                        sentByUser: false,
                        userId: userId,
                        conversationId: conversationId
                    )
                } else {
                    print("❌ No se encontraron respuestas del asistente")
                    // Si no hay respuesta del asistente, enviamos un mensaje de error
                    await MainActor.run {
                        self.currentMessage = MessageChatGPT(
                            text: "Lo siento, no pude procesar tu mensaje. Por favor, intenta de nuevo.",
                            role: .assistant
                        )
                        self.messages.append(self.currentMessage)
                        self.isProcessing = false
                    }
                    
                    registerMessageWithAlamofire(
                        message: "Lo siento, no pude procesar tu mensaje. Por favor, intenta de nuevo.",
                        sentByUser: false,
                        userId: userId,
                        conversationId: conversationId
                    )
                }
            } else {
                print("❌ Run no completado. Usando fallback.")
                // Si el run no se completó correctamente
                await MainActor.run {
                    self.currentMessage = MessageChatGPT(
                        text: "Hubo un problema al procesar tu mensaje. Por favor, intenta de nuevo.",
                        role: .assistant
                    )
                    self.messages.append(self.currentMessage)
                    self.isProcessing = false
                }
                
                registerMessageWithAlamofire(
                    message: "Hubo un problema al procesar tu mensaje. Por favor, intenta de nuevo.",
                    sentByUser: false,
                    userId: userId,
                    conversationId: conversationId
                )
            }
        } else {
            print("❌ No se pudo crear el run. Usando fallback.")
            // Fallback a SwiftOpenAI si hay algún problema con el thread o run
            await sendUsingSwiftOpenAI(message: message, isHidden: isHidden, userContext: userContext, conversationId: conversationId, userId: userId)
        }
    }
    
    // Método para añadir un mensaje al thread de OpenAI
    private func addMessageToThread(threadId: String, message: String) async -> Bool {
        do {
            let url = URL(string: "https://api.openai.com/v1/threads/\(threadId)/messages")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(OpenAIAPIKey.apiKey)", forHTTPHeaderField: "Authorization")
            request.addValue("assistants=v2", forHTTPHeaderField: "OpenAI-Beta")
            
            let messageData: [String: Any] = [
                "role": "user",
                "content": message
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: messageData)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error adding message to thread: \(response)")
                return false
            }
            
            return true
        } catch {
            print("Error adding message to thread: \(error.localizedDescription)")
            return false
        }
    }
    
    // Método para crear un run con el asistente
    private func createRun(threadId: String) async -> String? {
        do {
            let url = URL(string: "https://api.openai.com/v1/threads/\(threadId)/runs")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(OpenAIAPIKey.apiKey)", forHTTPHeaderField: "Authorization")
            request.addValue("assistants=v2", forHTTPHeaderField: "OpenAI-Beta")
            
            let runData: [String: Any] = [
                "assistant_id": assistantId
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: runData)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error creating run: \(response)")
                return nil
            }
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let runId = json["id"] as? String {
                return runId
            }
            
            return nil
        } catch {
            print("Error creating run: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Método para esperar a que el run se complete
    private func waitForRunCompletion(threadId: String, runId: String) async -> Bool {
        do {
            var isCompleted = false
            var attempts = 0
            let maxAttempts = 100 // Límite de intentos para evitar bucles infinitos
            
            while !isCompleted && attempts < maxAttempts {
                let url = URL(string: "https://api.openai.com/v1/threads/\(threadId)/runs/\(runId)")!
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("Bearer \(OpenAIAPIKey.apiKey)", forHTTPHeaderField: "Authorization")
                request.addValue("assistants=v2", forHTTPHeaderField: "OpenAI-Beta")
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Error checking run status: \(response)")
                    return false
                }
                
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let status = json["status"] as? String {
                    
                    if status == "completed" {
                        isCompleted = true
                    } else if status == "failed" || status == "cancelled" || status == "expired" {
                        print("Run failed with status: \(status)")
                        return false
                    } else {
                        // Esperar un segundo antes de verificar nuevamente
                        try await Task.sleep(nanoseconds: 1_000_000_000)
                        attempts += 1
                    }
                }
            }
            
            return isCompleted
        } catch {
            print("Error waiting for run completion: \(error.localizedDescription)")
            return false
        }
    }
    
    // Método para obtener los mensajes del thread
    private func getThreadMessages(threadId: String) async -> [AssistantMessage] {
        do {
            // Añadir parámetros a la URL para limitar y ordenar los mensajes
            let urlString = "https://api.openai.com/v1/threads/\(threadId)/messages?limit=10&order=desc"
            let url = URL(string: urlString)!
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(OpenAIAPIKey.apiKey)", forHTTPHeaderField: "Authorization")
            request.addValue("assistants=v2", forHTTPHeaderField: "OpenAI-Beta")
            
            print("🔍 Solicitando mensajes más recientes del thread: \(threadId)")
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("❌ Error getting thread messages: \(response)")
                if let httpResponse = response as? HTTPURLResponse {
                    print("Código de estado HTTP: \(httpResponse.statusCode)")
                    
                    // Intentar imprimir el cuerpo de la respuesta para más información
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            print("Respuesta de error: \(json)")
                        }
                    } catch {
                        print("No se pudo parsear la respuesta de error: \(error)")
                    }
                }
                return []
            }
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dataArray = json["data"] as? [[String: Any]] {
                
                print("✅ Se encontraron \(dataArray.count) mensajes en el thread")
                var messages: [AssistantMessage] = []
                
                for messageData in dataArray {
                    if let role = messageData["role"] as? String,
                       let contentArray = messageData["content"] as? [[String: Any]],
                       let firstContent = contentArray.first,
                       let text = firstContent["text"] as? [String: Any],
                       let value = text["value"] as? String,
                       let createdAt = messageData["created_at"] as? Int {
                        
                        print("Mensaje encontrado - Rol: \(role), Creado: \(createdAt)")
                        let message = AssistantMessage(role: role, content: value, createdAt: createdAt)
                        messages.append(message)
                    }
                }
                
                // Ordenar mensajes por fecha de creación (más reciente primero)
                let sortedMessages = messages.sorted { $0.createdAt > $1.createdAt }
                
                // Imprimir debug para ver mensajes ordenados
                for (index, message) in sortedMessages.enumerated() {
                    print("Mensaje #\(index) - Rol: \(message.role), Creado: \(message.createdAt)")
                }
                
                return sortedMessages
            }
            
            return []
        } catch {
            print("Error getting thread messages: \(error.localizedDescription)")
            return []
        }
    }
    
    ///Función original de SwiftOpenAI (como fallback)
    private func sendUsingSwiftOpenAI(message: String, isHidden: Bool = false, userContext: String, conversationId: Int, userId: Int) async {
        let optionalParameters = ChatCompletionsOptionalParameters(temperature: 0.7, stream: true, maxTokens: 1000)
        
        await MainActor.run {
            let userMessage = MessageChatGPT(text: message, role: .user, hidden: isHidden)
            let contextMessage = MessageChatGPT(text: userContext, role: .user, hidden: true)
            self.messages.append(contextMessage)
            self.messages.append(userMessage)
            
            self.currentMessage = MessageChatGPT(text: "", role: .assistant)
            self.messages.append(self.currentMessage)
        }
        // Registra el mensaje del usuario en la base de datos
            registerMessageWithAlamofire(message: message, sentByUser: true, userId: userId, conversationId: conversationId)
        
        do {
            let stream = try await openAI.createChatCompletionsStream(
                model: .gpt4(.base),
                messages: messages,
                optionalParameters: optionalParameters
            )
            
            for try await response in stream {
                print(response)
                await onReceive(newMessage: response, conversationId:  conversationId, userId : userId)
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    
    @MainActor
    private func onReceive(newMessage: ChatCompletionsStreamDataModel, conversationId : Int,  userId : Int) {
            let lastMessage = newMessage.choices[0]
            
        guard lastMessage.finishReason == nil else {
                print("finished sendin el message pa lol")
                registerMessageWithAlamofire(message: currentMessage.text, sentByUser: false, userId: userId, conversationId: conversationId)
                return
            }
            
        guard let content = lastMessage.delta?.content else {
                //print("message with no cont")
                return
            }
            
            currentMessage.text = currentMessage.text + content
            messages[messages.count - 1].text = currentMessage.text
            
            
        }

    
    // Utiliza APIClient para obtener el formulario del usuario
        func fetchUserForm(Users_id: Int) {
            APIClient.getN(path: "getUserForm/\(Users_id)") { [weak self] (result: Result<[UserForm], AFError>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let forms):
                        self?.userForm = forms
                        print("UserForm: \(forms)")
                    case .failure(let error):
                        print("Error fetching user form: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        // Utiliza APIClient para registrar un mensaje con Alamofire
        func registerMessageWithAlamofire(message: String, sentByUser: Bool, userId: Int, conversationId: Int) {
            let parameters: Parameters = [
                "text": message,
                "sentByUser": sentByUser,
                "user": userId,
                "conversationId": conversationId
            ]
            
            APIClient.postN(path: "addMessage", parameters: parameters) { response in
                switch response.result {
                case .success:
                    if let statusCode = response.response?.statusCode, statusCode == 200 {
                        print("Message registered successfully!")
                    } else {
                        print("Received unexpected status code: \(response.response?.statusCode ?? 0)")
                    }
                case .failure(let error):
                    print("Error registering message: \(error.localizedDescription)")
                }
            }
        }

    // Método para actualizar una conversación con un nuevo threadId
    func updateConversationWithThreadId(conversationId: Int, threadId: String) async -> Bool {
        print("Actualizando la conversación \(conversationId) con el nuevo threadId: \(threadId)")
        
        let parameters: Parameters = [
            "thread_id": threadId
        ]
        
        // Usar el método correcto para realizar la solicitud PUT de manera asíncrona
        do {
            let _: UpdateConversationResponse = try await APIClient.put(
                path: "updateConversationThreadId/\(conversationId)",
                parameters: parameters
            )
            print("ThreadId actualizado correctamente en la base de datos")
            return true
        } catch {
            print("Error al actualizar el threadId en la base de datos: \(error.localizedDescription)")
            
            // Intento alternativo usando un endpoint diferente
            do {
                let _: UpdateConversationResponse = try await APIClient.put(
                    path: "conversation/\(conversationId)/update",
                    parameters: parameters
                )
                print("ThreadId actualizado con endpoint alternativo")
                return true
            } catch {
                print("Error con endpoint alternativo: \(error.localizedDescription)")
                return false
            }
        }
    }

    // Método para depurar el estado actual del thread_id
    private func debugThreadId(conversationId: Int) {
        print("--- ESTADO DEL THREAD_ID ---")
        print("Conversation ID: \(conversationId)")
        print("Thread ID actual: \(currentThreadId ?? "No disponible")")
        
        // Verificar el valor de la API key
        if OpenAIAPIKey.isValid() {
            print("API Key: ✅ Válida")
        } else {
            print("API Key: ❌ No válida")
        }
        
        print("--------------------------")
    }
}

// Estructura para manejar los mensajes del asistente
struct AssistantMessage {
    let role: String
    let content: String
    let createdAt: Int
}
