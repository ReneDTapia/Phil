//
//  GPTViewModel.swift
//  Phil
//
//  Created by Jesús Daniel Martínez García on 19/10/23.
//

import SwiftUI
import SwiftOpenAI
import Alamofire
import os

final class GPTViewModel : ObservableObject {
    @Published var userForm : [UserForm] = []
    @Published var messages : [MessageChatGPT] = [
        .init(text: "Actúa como un psicologo llamado Phil y en todos mis mensajes ten en cuenta la siguiente informacion que te mandaré como contexto y si te pregunto algo con relación a lo siguiente ayudame a entenderlo como psicólogo. Si después de este mensaje te envio algo que no este relacionado con salud mental o psicología entonces contesta que solo me puedes responder preguntas de estos temas" , role: .system, hidden: true)
    ]
    
    @Published var currentMessage : MessageChatGPT = .init(text: "", role: .assistant)
    
    private let apiKey = "YOUR_API_KEY"
    private let assistantId = "asst_zjqrUTBWpkf47QWfFRXxDS2R"
    private let baseURL = "https://api.openai.com/v1"
    
    private let logger = Logger(subsystem: "com.phil.app", category: "GPTViewModel")
    
    private func createThread() async throws -> (id: String, created_at: Int) {
        return try await withCheckedThrowingContinuation { continuation in
            AF.request("\(baseURL)/threads",
                      method: .post,
                      headers: [
                        "Authorization": "Bearer \(apiKey)",
                        "Content-Type": "application/json"
                      ])
                .responseDecodable(of: ThreadResponse.self) { response in
                    switch response.result {
                    case .success(let threadResponse):
                        continuation.resume(returning: (threadResponse.id, threadResponse.created_at))
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
    
    private func addMessageToThread(threadId: String, content: String) async throws -> MessageResponse {
        return try await withCheckedThrowingContinuation { continuation in
            let parameters: [String: Any] = ["role": "user", "content": content]
            
            AF.request("\(baseURL)/threads/\(threadId)/messages",
                      method: .post,
                      parameters: parameters,
                      encoding: JSONEncoding.default,
                      headers: [
                        "Authorization": "Bearer \(apiKey)",
                        "Content-Type": "application/json"
                      ])
                .responseDecodable(of: MessageResponse.self) { response in
                    switch response.result {
                    case .success(let messageResponse):
                        continuation.resume(returning: messageResponse)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
    
    private func createRun(threadId: String) async throws -> RunResponse {
        return try await withCheckedThrowingContinuation { continuation in
            let parameters: [String: Any] = ["assistant_id": assistantId]
            
            AF.request("\(baseURL)/threads/\(threadId)/runs",
                      method: .post,
                      parameters: parameters,
                      encoding: JSONEncoding.default,
                      headers: [
                        "Authorization": "Bearer \(apiKey)",
                        "Content-Type": "application/json"
                      ])
                .responseDecodable(of: RunResponse.self) { response in
                    switch response.result {
                    case .success(let runResponse):
                        continuation.resume(returning: runResponse)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
    
    private func retrieveRun(threadId: String, runId: String) async throws -> RunResponse {
        return try await withCheckedThrowingContinuation { continuation in
            AF.request("\(baseURL)/threads/\(threadId)/runs/\(runId)",
                      method: .get,
                      headers: [
                        "Authorization": "Bearer \(apiKey)",
                        "Content-Type": "application/json"
                      ])
                .responseDecodable(of: RunResponse.self) { response in
                    switch response.result {
                    case .success(let runResponse):
                        continuation.resume(returning: runResponse)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
    
    private func listMessages(threadId: String) async throws -> [MessageResponse] {
        return try await withCheckedThrowingContinuation { continuation in
            AF.request("\(baseURL)/threads/\(threadId)/messages",
                      method: .get,
                      headers: [
                        "Authorization": "Bearer \(apiKey)",
                        "Content-Type": "application/json"
                      ])
                .responseDecodable(of: MessagesListResponse.self) { response in
                    switch response.result {
                    case .success(let messagesResponse):
                        continuation.resume(returning: messagesResponse.data)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
    
    struct ThreadResponse: Codable {
        let id: String
        let created_at: Int
    }
    
    struct MessageResponse: Codable {
        let id: String
        let role: String
        let content: [ContentItem]
        
        struct ContentItem: Codable {
            let text: TextContent
        }
        
        struct TextContent: Codable {
            let value: String
        }
    }
    
    struct MessagesListResponse: Codable {
        let data: [MessageResponse]
    }
    
    struct RunResponse: Codable {
        let id: String
        let status: String
    }
    
    private func formatUserContext() -> String {
        logger.debug("Formatting user form data. Number of form items: \(self.userForm.count)")
        
        let formattedData = userForm.map { form in
            """
            Pregunta: \(form.texto)
            Porcentaje de identificación: \(form.Percentage)0%
            """
        }.joined(separator: "\n\n")
        
        let context = """
        Contexto del usuario:
        El usuario ha respondido las siguientes preguntas sobre su salud mental. Por favor, considera esta información para todas tus respuestas y recomendaciones:
        
        \(formattedData)
        
        Recuerda:
        - Entre más alto el porcentaje, más se identifica el usuario con esa situación
        - Basa tus respuestas en este contexto para dar recomendaciones más personalizadas
        - Solo responde preguntas relacionadas con salud mental y psicología
        """
        
        logger.debug("Generated context: \(context)")
        return context
    }
    
    func send(message: String, isHidden: Bool = false, userContext: String? = nil, conversationId: Int, userId: Int) async {
        do {
            logger.info("Starting new chat interaction - ConversationId: \(conversationId)")
            
            // Create thread
            let (threadId, _) = try await createThread()
            logger.debug("Created new thread: \(threadId)")
            
            // Use provided context or generate from user form
            let contextToSend = userContext ?? formatUserContext()
            logger.debug("Using context: \(contextToSend.prefix(100))...") // Log first 100 chars
            
            // Store message responses
            logger.debug("Sending context message to thread")
            _ = try await addMessageToThread(threadId: threadId, content: contextToSend)
            
            logger.debug("Sending user message: \(message)")
            _ = try await addMessageToThread(threadId: threadId, content: message)
            
            logger.debug("Creating run with assistant")
            let run = try await createRun(threadId: threadId)
            
            var currentRun = run
            while currentRun.status != "completed" {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                logger.debug("Waiting for run completion. Current status: \(currentRun.status)")
                currentRun = try await retrieveRun(threadId: threadId, runId: run.id)
            }
            
            logger.debug("Run completed, fetching messages")
            let messages = try await listMessages(threadId: threadId)
            
            await MainActor.run {
                logger.debug("Updating UI with messages")
                let userMessage = MessageChatGPT(text: message, role: .user, hidden: isHidden)
                self.messages.append(userMessage)
                
                if let assistantMessage = messages.first(where: { $0.role == "assistant" }) {
                    self.currentMessage = MessageChatGPT(text: assistantMessage.content[0].text.value, role: .assistant)
                    self.messages.append(self.currentMessage)
                }
            }
            
            logger.debug("Registering user message in database")
            registerMessageWithAlamofire(
                message: message,
                sentByUser: true,
                userId: userId,
                conversationId: conversationId,
                threadId: threadId
            )
            
            if let assistantMessage = messages.first(where: { $0.role == "assistant" }) {
                logger.debug("Registering assistant message in database")
                registerMessageWithAlamofire(
                    message: assistantMessage.content[0].text.value,
                    sentByUser: false,
                    userId: userId,
                    conversationId: conversationId,
                    threadId: threadId
                )
            }
            
        } catch {
            logger.error("Error in send: \(error.localizedDescription)")
            print("Error in send: \(error)")
        }
    }
    
    func registerMessageWithAlamofire(message: String, sentByUser: Bool, userId: Int, conversationId: Int, threadId: String) {
        let parameters: Parameters = [
            "text": message,
            "sentByUser": sentByUser,
            "user": userId,
            "conversationId": conversationId,
            "threadId": threadId
        ]
        
        logger.debug("Registering message: sentByUser=\(sentByUser), conversationId=\(conversationId), threadId=\(threadId)")
        
        APIClient.postN(path: "addMessage", parameters: parameters) { response in
            switch response.result {
            case .success:
                if let statusCode = response.response?.statusCode, statusCode == 200 {
                    self.logger.info("Message registered successfully!")
                } else {
                    self.logger.error("Unexpected status code: \(response.response?.statusCode ?? 0)")
                }
            case .failure(let error):
                self.logger.error("Error registering message: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchUserForm(Users_id: Int) {
        logger.debug("Fetching user form for user: \(Users_id)")
        
        APIClient.getN(path: "getUserForm/\(Users_id)") { [weak self] (result: Result<[UserForm], AFError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let forms):
                    self?.userForm = forms
                    self?.logger.info("Successfully fetched user form with \(forms.count) items")
                case .failure(let error):
                    self?.logger.error("Error fetching user form: \(error.localizedDescription)")
                }
            }
        }
    }
}
