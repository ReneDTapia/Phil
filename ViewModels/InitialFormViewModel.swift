//
//  InitialFormViewModel.swift
//  Phil
//
//  Created by Leonardo García Ledezma on 17/10/23.
//

import Foundation
import SwiftUI


class InitialFormViewModel: ObservableObject {
    @Published var formGroups: [[InitialFormModel]] = []
    @Published var selectedButtons: [[Int]] = Array(repeating: [], count: 4)
    @Published var selectedCount = 0
    
    
    func getForm() {
        guard let url = URL(string: "http://localhost:5005/api/auth/getForm") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                if let data = data {
                    let forms = try JSONDecoder().decode([InitialFormModel].self, from: data)
                    DispatchQueue.main.async {
                        self.formGroups = Dictionary(grouping: forms, by: { $0.order })
                            .sorted(by: { $0.key < $1.key })
                            .map({ $0.value })
                    }
                } else {
                    print("No data")
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    func postAnswers() {
        // Crear la URL para la solicitud
        guard let url = URL(string: "http://localhost:5005/api/auth/postForm") else {
            print("URL inválida")
            return
        }

        // Recoger las respuestas seleccionadas
        let selectedAnswers = selectedButtons.compactMap { $0 }

        // Crear el cuerpo de la solicitud
        let body: [String: Any] = ["Users_id": 1, "Cuestionario_id": 1, "checked": selectedAnswers]
        let finalBody = try? JSONSerialization.data(withJSONObject: body)

        // Crear la solicitud
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = finalBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Enviar la solicitud
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error al enviar las respuestas: \(error)")
            } else if let data = data {
                let str = String(data: data, encoding: .utf8)
                print("Respuesta recibida: \(str ?? "")")
            }
        }.resume()
    }
}



/*
 struct FormData: Codable {
 let value: Int
 }
 func sendPostRequest(value: Int) {
 // Crear una URL para tu API
 guard let url = URL(string: "https://tu-api.com/ruta") else {
 print("Invalid URL")
 return
 }
 // Crear tu objeto de datos
 let formData = FormData(value: value)
 
 // Convertir tu objeto de datos en JSON
 guard let jsonData = try? JSONEncoder().encode(formData) else {
 print("Failed to encode data")
 return
 }
 // Crear la solicitud POST
 var request = URLRequest(url: url)
 request.httpMethod = "POST"
 request.httpBody = jsonData
 request.setValue("application/json", forHTTPHeaderField: "Content-Type")
 
 // Enviar la solicitud POST
 URLSession.shared.dataTask(with: request) { data, response, error in
 if let error = error {
 print("Error: \(error)")
 } else if let response = response as? HTTPURLResponse {
 print("Response status code: \(response.statusCode)")
 }
 }.resume()
 }
 */

