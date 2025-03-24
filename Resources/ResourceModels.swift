//
//  ResourceModels.swift
//  Phil
//
//  Created by Dario on 24/03/25.
//

import Foundation
import SwiftUI


// Base protocol for all mental health resources
protocol MentalHealthResource: Identifiable {
    var id: UUID { get }
    var name: String { get }
    var description: String { get }
}

// MARK: - Crisis Helpline Models

struct CrisisHelpline: MentalHealthResource {
    let id = UUID()
    let name: String
    let description: String
    let phoneNumber: String
    let availability: String // e.g., "24/7", "8AM-8PM"
    let supportTypes: [SupportType]
    
    // Dedicated initializer for better clarity and validation
    init(name: String, description: String, phoneNumber: String, availability: String, supportTypes: [SupportType]) {
        self.name = name
        self.description = description
        self.phoneNumber = phoneNumber
        self.availability = availability
        self.supportTypes = supportTypes
    }
}

enum SupportType: String, CaseIterable, Identifiable {
    case crisis = "Crisis"
    case suicide = "Suicide Prevention"
    case addiction = "Addiction"
    case domesticViolence = "Domestic Violence"
    case mentalHealth = "General Mental Health"
    
    var id: String { self.rawValue }
}

// MARK: - Support Group Models

struct SupportGroup: MentalHealthResource {
    let id = UUID()
    let name: String
    let description: String
    let meetingFormat: MeetingFormat
    let schedule: String
    let location: String?
    let onlineLink: String?
    let focusArea: String
    let facilitator: String?
    
    // Computed property for meeting location display
    var meetingLocation: String {
        if meetingFormat == .online {
            return "Online"
        } else if let location = location {
            return location
        } else {
            return "Location details available upon registration"
        }
    }
}

enum MeetingFormat: String, CaseIterable, Identifiable {
    case inPerson = "In-Person"
    case online = "Online"
    case hybrid = "Hybrid"
    
    var id: String { self.rawValue }
}

// MARK: - Self-Help Tool Models

struct SelfHelpTool: MentalHealthResource {
    let id = UUID()
    let name: String
    let description: String
    let category: ToolCategory
    let format: ToolFormat
    let duration: String?
    let difficulty: ToolDifficulty
    let imageURL: String?
}

enum ToolCategory: String, CaseIterable, Identifiable {
    case meditation = "Meditation"
    case mindfulness = "Mindfulness"
    case journaling = "Journaling"
    case breathing = "Breathing Exercises"
    case cognitive = "Cognitive Exercises"
    case physical = "Physical Activity"
    
    var id: String { self.rawValue }
}

enum ToolFormat: String, CaseIterable, Identifiable {
    case exercise = "Exercise"
    case article = "Article"
    case audio = "Audio"
    case video = "Video"
    case interactive = "Interactive Tool"
    
    var id: String { self.rawValue }
}

enum ToolDifficulty: String, CaseIterable, Identifiable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .blue
        case .advanced: return .purple
        }
    }
}
