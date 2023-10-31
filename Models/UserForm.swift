//
//  UserForm.swift
//  Phil
//
//  Created by Jesús Daniel Martínez García on 23/10/23.
//

import Foundation

//Este modelo nos sirve para las preguntas respondidas por X usuario.    TODO USADO EN GPT VIEW MODEL POR PRACTICIDAD :::

struct UserForm: Identifiable, Decodable {
    let id: Int
    let texto: String
    let checked: Bool
    
    enum CodingKeys: String, CodingKey {
        case texto
        case checked
        case id = "Users_Cuestionario_id"
    }
}
