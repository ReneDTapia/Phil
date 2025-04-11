//
//  ResourceModelExtensions.swift
//  Phil
//
//  Created by Mar Reyes on 10/04/2025.
//


//
//  ResourceModelExtensions.swift
//  Phil
//
//  Created by Dario on 24/03/25.
//

import Foundation

// MARK: - Crisis Helpline Sample Data
extension CrisisHelpline {
    static var sampleHelplines: [CrisisHelpline] {
        [
            CrisisHelpline(
                name: "Línea Nacional de Apoyo Emocional (SAPTEL)",
                description: "Servicio gratuito de atención telefónica para personas con problemas emocionales, crisis psicológicas o ideación suicida.",
                phoneNumber: "55-5259-8121",
                availability: "24/7",
                supportTypes: [.crisis, .suicide, .mentalHealth]
            ),
            CrisisHelpline(
                name: "Consejo Ciudadano para la Seguridad",
                description: "Línea de atención psicológica gratuita para crisis, ansiedad, depresión y prevención del suicidio.",
                phoneNumber: "55-5533-5533",
                availability: "24/7",
                supportTypes: [.crisis, .mentalHealth, .suicide]
            ),
            CrisisHelpline(
                name: "Línea de Ayuda en Adicciones (CONADIC)",
                description: "Orientación, intervención y canalización para personas con problemas de consumo de sustancias.",
                phoneNumber: "800-911-2000",
                availability: "24/7",
                supportTypes: [.addiction, .mentalHealth]
            ),
            CrisisHelpline(
                name: "Línea Mujer (INMUJERES)",
                description: "Línea nacional para mujeres que sufren violencia de género, ofreciendo orientación y apoyo inmediato.",
                phoneNumber: "800-0911-466",
                availability: "24/7",
                supportTypes: [.crisis, .domesticViolence]
            ),
            CrisisHelpline(
                name: "Línea UAM de Apoyo Psicológico",
                description: "Servicio telefónico de la Universidad Autónoma Metropolitana para apoyo emocional y psicológico.",
                phoneNumber: "55-5804-6444",
                availability: "Lunes a viernes 9:00-17:00",
                supportTypes: [.mentalHealth, .crisis]
            ),
            CrisisHelpline(
                name: "Emergencias Locatel CDMX",
                description: "Línea de emergencias y apoyo psicológico en la Ciudad de México.",
                phoneNumber: "55-5658-1111",
                availability: "24/7",
                supportTypes: [.crisis, .mentalHealth]
            )
        ]
    }
}

// MARK: - Support Group Sample Data
extension SupportGroup {
    static var sampleGroups: [SupportGroup] {
        [
            SupportGroup(
                name: "Anxiety Support Circle",
                description: "A supportive community for individuals dealing with anxiety, panic disorders, and related conditions.",
                meetingFormat: .hybrid,
                schedule: "Tuesdays at 7:00 PM",
                location: "Community Center, 123 Main St",
                onlineLink: "https://zoom.us/j/anxietysupport",
                focusArea: "Anxiety & Panic Disorders",
                facilitator: "Dr. Emily Johnson"
            ),
            SupportGroup(
                name: "Depression Recovery Group",
                description: "A peer-led group focused on coping strategies and mutual support for those experiencing depression.",
                meetingFormat: .inPerson,
                schedule: "Mondays at 6:30 PM",
                location: "Health Services Building, Room 302",
                onlineLink: nil,
                focusArea: "Depression",
                facilitator: "Michael Chen, LCSW"
            ),
            SupportGroup(
                name: "Online Grief Support",
                description: "A compassionate space for those dealing with loss and grief, focused on healing and moving forward.",
                meetingFormat: .online,
                schedule: "Saturdays at 10:00 AM",
                location: nil,
                onlineLink: "https://meetup.com/grief-support",
                focusArea: "Grief & Loss",
                facilitator: "Sarah Rodriguez, PhD"
            ),
            SupportGroup(
                name: "LGBTQ+ Mental Health Alliance",
                description: "A safe community for LGBTQ+ individuals to discuss mental health challenges and build resilience.",
                meetingFormat: .hybrid,
                schedule: "Thursdays at 7:30 PM",
                location: "LGBTQ Center, 456 Oak Avenue",
                onlineLink: "https://teams.microsoft.com/lgbtqalliance",
                focusArea: "LGBTQ+ Mental Health",
                facilitator: "Alex Wong, LPC"
            ),
            SupportGroup(
                name: "Addiction Recovery Network",
                description: "A supportive community for individuals in all stages of recovery from substance use disorders.",
                meetingFormat: .inPerson,
                schedule: "Wednesdays & Sundays at 6:00 PM",
                location: "Community Hospital, Conference Room B",
                onlineLink: nil,
                focusArea: "Substance Use Recovery",
                facilitator: "James Wilson, CADC"
            )
        ]
    }
}

// MARK: - Self-Help Tool Sample Data
extension SelfHelpTool {
    static var sampleTools: [SelfHelpTool] {
        [
            SelfHelpTool(
                name: "5-Minute Calming Breath",
                description: "A simple guided breathing exercise to help reduce anxiety and stress in the moment.",
                category: .breathing,
                format: .audio,
                duration: "5 minutes",
                difficulty: .beginner,
                imageURL: nil
            ),
            SelfHelpTool(
                name: "Mindful Body Scan Meditation",
                description: "A guided meditation to bring awareness to different parts of your body to release tension.",
                category: .meditation,
                format: .audio,
                duration: "15 minutes",
                difficulty: .beginner,
                imageURL: nil
            ),
            SelfHelpTool(
                name: "Cognitive Distortions Workshop",
                description: "Learn to identify and challenge unhelpful thought patterns that contribute to anxiety and depression.",
                category: .cognitive,
                format: .interactive,
                duration: "30 minutes",
                difficulty: .intermediate,
                imageURL: nil
            ),
            SelfHelpTool(
                name: "Gratitude Journaling Guide",
                description: "A structured approach to keeping a gratitude journal with proven mental health benefits.",
                category: .journaling,
                format: .article,
                duration: nil,
                difficulty: .beginner,
                imageURL: nil
            ),
            SelfHelpTool(
                name: "Progressive Muscle Relaxation",
                description: "Learn to systematically tense and release different muscle groups to reduce physical tension.",
                category: .physical,
                format: .video,
                duration: "20 minutes",
                difficulty: .beginner,
                imageURL: nil
            ),
            SelfHelpTool(
                name: "Advanced Mindfulness Practices",
                description: "Deepen your mindfulness practice with these advanced techniques for experienced practitioners.",
                category: .mindfulness,
                format: .video,
                duration: "45 minutes",
                difficulty: .advanced,
                imageURL: nil
            ),
            SelfHelpTool(
                name: "Anxiety Thought Record",
                description: "A structured template to identify and reframe anxious thoughts using CBT principles.",
                category: .cognitive,
                format: .interactive,
                duration: nil,
                difficulty: .intermediate,
                imageURL: nil
            )
        ]
    }
}