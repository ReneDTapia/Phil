//
//  DoctorsModel.swift
//  Phil
//
//  Created by Jesús Daniel Martínez García on 18/03/25.
//

import Foundation

struct Doctor: Identifiable, Decodable {
    var id: Int
    var name: String
    var categories: [String]
    var specialties: String
    var rating: Double
    var reviewCount: Int
    var availability: AvailabilityStatus
    var modes: [ConsultationMode]
    var price: Int
    var imageURL: String?
    var description: String?
    
    // Si necesitamos obtener doctores de forma simulada para pruebas o desarrollo
    static var sampleDoctors: [Doctor] {
        [
            Doctor(
                id: 1000,
                name: "Dr. Sarah Johnson",
                categories: ["x"],
                specialties: "Anxiety & Depression",
                rating: 4.9,
                reviewCount: 124,
                availability: .specificDay("Friday"),
                modes: [.online, .inPerson],
                price: 120,
                imageURL: nil,
                description: "Xd"
                
            ),
            Doctor(
                id: 1001,
                name: "Dr. Michael Chen",
                categories: ["x"],
                specialties: "Trauma & PTSD",
                rating: 4.7,
                reviewCount: 98,
                availability: .specificDay("Friday"),
                modes: [.online],
                price: 150,
                imageURL: nil
            ),
            Doctor(
                id: 1003,
                name: "Dr. Emily Rodriguez",
                categories: ["x"],
                specialties: "Relationship Issues",
                rating: 4.8,
                reviewCount: 156,
                availability: .specificDay("Friday"),
                modes: [.online, .inPerson],
                price: 135,
                imageURL: nil
            )
        ]
    }
}

// Estado de disponibilidad del doctor
enum AvailabilityStatus: Codable {
    case specificDay(String)

    var displayText: String {
        switch self {
        case .specificDay(let day):
            return "Next available: \(day)"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case specificDay
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let day = try container.decode(String.self, forKey: .specificDay)
        self = .specificDay(day)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .specificDay(let day):
            try container.encode(day, forKey: .specificDay)
        }
    }
}



// Modalidades de consulta
enum ConsultationMode: String, CaseIterable, Identifiable, Decodable {
    case online = "En Linea"
    case inPerson = "Presencial"
    
    var id: String { self.rawValue }
}
