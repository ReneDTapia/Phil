//
//  DoctorsModel.swift
//  Phil
//
//  Created by Jesús Daniel Martínez García on 18/03/25.
//

import Foundation

struct Doctor: Identifiable {
    var id = UUID()
    var name: String
    var specialties: String
    var rating: Double
    var reviewCount: Int
    var availability: AvailabilityStatus
    var modes: [ConsultationMode]
    var price: Int
    var imageURL: String?
    
    // Si necesitamos obtener doctores de forma simulada para pruebas o desarrollo
    static var sampleDoctors: [Doctor] {
        [
            Doctor(
                name: "Dr. Sarah Johnson",
                specialties: "Anxiety & Depression",
                rating: 4.9,
                reviewCount: 124,
                availability: .today,
                modes: [.online, .inPerson],
                price: 120,
                imageURL: nil
            ),
            Doctor(
                name: "Dr. Michael Chen",
                specialties: "Trauma & PTSD",
                rating: 4.7,
                reviewCount: 98,
                availability: .tomorrow,
                modes: [.online],
                price: 150,
                imageURL: nil
            ),
            Doctor(
                name: "Dr. Emily Rodriguez",
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
enum AvailabilityStatus {
    case today
    case tomorrow
    case specificDay(String) // Ej: "Friday", "Next week", etc.
    
    var displayText: String {
        switch self {
        case .today:
            return "Available today"
        case .tomorrow:
            return "Next available: Tomorrow"
        case .specificDay(let day):
            return "Next available: \(day)"
        }
    }
}

// Modalidades de consulta
enum ConsultationMode: String, CaseIterable, Identifiable {
    case online = "Online"
    case inPerson = "In-person"
    
    var id: String { self.rawValue }
}
