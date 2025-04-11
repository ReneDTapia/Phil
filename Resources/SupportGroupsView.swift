//  SupportGroupsView.swift
//  Phil
//
//  Created by Dario on 3/22/25.
//

import SwiftUI

struct SupportGroupsView: View {
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
                        
                        Text("Grupos de Apoyo")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Search bar placeholder
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        Text("Buscar grupos de apoyo...")
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
                
                // Sample content
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Encuentra apoyo en tu comunidad o en línea")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 4)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        // Sección de Grupos de Apoyo
                        Text("Grupos de Apoyo")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        // Grupos de apoyo mexicanos
                        sampleSupportGroup(
                            name: "Grupo de Apoyo para Ansiedad",
                            focusArea: "Ansiedad y Trastornos de Pánico",
                            location: "Hospital Ángeles, CDMX",
                            schedule: "Martes 18:00",
                            isOnline: false,
                            url: "https://www.hospitalangeles.com/salud-mental"
                        )
                        
                        sampleSupportGroup(
                            name: "Unidos contra la Depresión",
                            focusArea: "Depresión y Salud Mental",
                            location: "Centro Comunitario, Monterrey",
                            schedule: "Lunes 17:30",
                            isOnline: false,
                            url: "https://www.facebook.com/unidoscontraladepresion"
                        )
                        
                        sampleSupportGroup(
                            name: "Red de Duelo y Pérdida",
                            focusArea: "Duelo y Proceso de Pérdida",
                            location: "Virtual - Zoom",
                            schedule: "Sábados 10:00",
                            isOnline: true,
                            url: "https://www.reddeduelo.org"
                        )
                        
                        sampleSupportGroup(
                            name: "Alianza LGBTQ+ por la Salud Mental",
                            focusArea: "Comunidad LGBTQ+",
                            location: "Centro LGBTQ+, Guadalajara",
                            schedule: "Jueves 19:00",
                            isOnline: true,
                            url: "https://www.alianzalgbttti.org"
                        )
                        
                        sampleSupportGroup(
                            name: "Grupo de Recuperación de Adicciones",
                            focusArea: "Adicciones y Recuperación",
                            location: "Centro de Integración Juvenil, CDMX",
                            schedule: "Miércoles y Domingos 18:00",
                            isOnline: false,
                            url: "https://www.cij.gob.mx"
                        )
                        
                        sampleSupportGroup(
                            name: "Familias y TOC",
                            focusArea: "Trastorno Obsesivo Compulsivo",
                            location: "Virtual - Google Meet",
                            schedule: "Viernes 19:30",
                            isOnline: true,
                            url: "https://www.familiasytoc.org"
                        )
                        
                        // Sección de Recursos de Autoayuda
                        Text("Recursos de Autoayuda")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 20)
                        
                        // Recursos de autoayuda
                        sampleSupportGroup(
                            name: "Guías de Autoayuda - IMSS",
                            focusArea: "Material de apoyo psicológico",
                            location: "Recursos en línea",
                            schedule: "Disponible 24/7",
                            isOnline: true,
                            url: "https://www.imss.gob.mx/salud-en-linea/salud-mental"
                        )
                        
                        sampleSupportGroup(
                            name: "Cuadernos de Autoayuda - UNAM",
                            focusArea: "Material educativo y ejercicios",
                            location: "Recursos en línea",
                            schedule: "Disponible 24/7",
                            isOnline: true,
                            url: "https://www.psicologia.unam.mx/recursos/autoayuda"
                        )
                        
                        sampleSupportGroup(
                            name: "Aplicación de Meditación",
                            focusArea: "Mindfulness y relajación",
                            location: "App disponible en español",
                            schedule: "Disponible 24/7",
                            isOnline: true,
                            url: "https://www.headspace.com/es"
                        )
                        
                        sampleSupportGroup(
                            name: "Cursos en Línea de Salud Mental",
                            focusArea: "Aprendizaje autodirigido",
                            location: "Plataforma educativa",
                            schedule: "Disponible 24/7",
                            isOnline: true,
                            url: "https://www.coursera.org/browse/health/mental-health"
                        )
                        
                        sampleSupportGroup(
                            name: "Podcasts de Salud Mental",
                            focusArea: "Contenido educativo y de apoyo",
                            location: "Plataformas de audio",
                            schedule: "Nuevos episodios semanales",
                            isOnline: true,
                            url: "https://open.spotify.com/genre/mental-health-podcasts"
                        )
                        
                        // Nota informativa
                        Text("Estos recursos son complementarios y no sustituyen la atención profesional. Si necesitas ayuda inmediata, contacta a un profesional de la salud mental.")
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
    
    // Sample support group card
    private func sampleSupportGroup(name: String, focusArea: String, location: String, schedule: String, isOnline: Bool, url: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(focusArea)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
            }
            
            // Format badge
            HStack(spacing: 8) {
                if isOnline {
                    Label("Virtual", systemImage: "video.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Label("Presencial", systemImage: "person.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption)
                    Text(location)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                Text(schedule)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 2)
            
            // Join button
            Button(action: {
                if let url = URL(string: url) {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack {
                    Image(systemName: "person.badge.plus")
                        .font(.headline)
                    Text("Más Información y Registro")
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

struct SupportGroupsView_Previews: PreviewProvider {
    static var previews: some View {
        SupportGroupsView()
    }
}
