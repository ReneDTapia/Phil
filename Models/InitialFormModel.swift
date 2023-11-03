//
//  InitialFormModel.swift
//  Phil
//
//  Created by Leonardo García Ledezma on 18/10/23.
//

struct InitialFormModel: Codable, Identifiable, Hashable {
    let id: Int
    let texto: String
    let order: Int

    // Implementación de Hashable
    static func == (lhs: InitialFormModel, rhs: InitialFormModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

