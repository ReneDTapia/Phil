//
//  SelfHelpToolsView.swift
//  Phil
//
//  Created by Mar Reyes on 10/04/2025.
//


//
//  SelfHelpToolsView.swift
//  Phil
//
//  Created by Dario on 24/03/25.
//

import SwiftUI

struct SelfHelpToolsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.primary)
                                .padding(10)
                                .background(Circle().fill(Color.white))
                                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                        }
                        
                        Text("Herramientas de Autoayuda")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Search bar placeholder
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        Text("Buscar herramientas...")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(25)
                    .padding(.horizontal)
                }
                .padding(.vertical, 16)
                .background(Color.white)
                
                // Contenido
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Recursos y herramientas para tu bienestar emocional")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 4)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        // Sección de Material Educativo
                        Text("Material Educativo")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        selfHelpToolCard(
                            name: "Guías de Autoayuda IMSS",
                            description: "Material de apoyo psicológico y guías prácticas",
                            category: "Documentos",
                            url: "https://www.imss.gob.mx/salud-en-linea/salud-mental"
                        )
                        
                        selfHelpToolCard(
                            name: "Cuadernos de Trabajo UNAM",
                            description: "Ejercicios y actividades para el manejo emocional",
                            category: "Ejercicios",
                            url: "https://www.psicologia.unam.mx/recursos/autoayuda"
                        )
                        
                        // Sección de Aplicaciones
                        Text("Aplicaciones Móviles")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 20)
                        
                        selfHelpToolCard(
                            name: "Headspace en Español",
                            description: "Meditación guiada y mindfulness",
                            category: "Meditación",
                            url: "https://www.headspace.com/es"
                        )
                        
                        selfHelpToolCard(
                            name: "Sanvello",
                            description: "Seguimiento del estado de ánimo y ejercicios",
                            category: "Seguimiento",
                            url: "https://www.sanvello.com"
                        )
                        
                        // Sección de Podcasts
                        Text("Podcasts y Audio")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 20)
                        
                        selfHelpToolCard(
                            name: "Psicología al Día",
                            description: "Consejos prácticos y entrevistas con expertos",
                            category: "Podcast",
                            url: "https://open.spotify.com/show/psicologiaaldia"
                        )
                        
                        selfHelpToolCard(
                            name: "Mente en Calma",
                            description: "Meditaciones guiadas en español",
                            category: "Meditación",
                            url: "https://open.spotify.com/show/menteencalma"
                        )
                        
                        // Sección de Videos
                        Text("Videos y Tutoriales")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 20)
                        
                        selfHelpToolCard(
                            name: "Canal de Psicología UNAM",
                            description: "Videos educativos sobre salud mental",
                            category: "Educación",
                            url: "https://www.youtube.com/c/PsicologiaUNAM"
                        )
                        
                        selfHelpToolCard(
                            name: "Técnicas de Relajación",
                            description: "Ejercicios prácticos de respiración",
                            category: "Ejercicios",
                            url: "https://www.youtube.com/playlist?list=tecnicasrelajacion"
                        )
                        
                        // Nota informativa
                        Text("Recuerda que estas herramientas son complementarias y no sustituyen la atención profesional. Si necesitas ayuda inmediata, contacta a un profesional de la salud mental.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top, 16)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // Tarjeta de herramienta de autoayuda
    private func selfHelpToolCard(name: String, description: String, category: String, url: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            
            // Categoría
            HStack {
                Text(category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.indigo.opacity(0.1))
                    .foregroundColor(.indigo)
                    .cornerRadius(8)
                
                Spacer()
            }
            
            // Botón de acceso
            Button(action: {
                if let url = URL(string: url) {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack {
                    Image(systemName: "arrow.right.circle")
                        .font(.headline)
                    Text("Acceder al Recurso")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.indigo)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
}

struct SelfHelpToolsView_Previews: PreviewProvider {
    static var previews: some View {
        SelfHelpToolsView()
    }
}