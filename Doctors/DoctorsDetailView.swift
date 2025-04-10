//
//  DoctorsDetailView.swift
//  Phil
//
//  Created by Jesús Daniel Martínez García on 19/03/25.
//

import SwiftUI

struct DoctorsDetailView: View {
    let doctor: Doctor
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        ZStack {
            // Fondo principal
            Color(.systemGray6)
                .ignoresSafeArea()
            
            // Contenido principal
            VStack(spacing: 0) {
                // Header con imagen y foto del doctor
                ZStack(alignment: .top) {
                    // Imagen de fondo con gradiente
                    Rectangle()
                        .foregroundColor(Color(.systemGray5))
                        .frame(height: 200)
                        .edgesIgnoringSafeArea(.top)
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.3)]),
                                startPoint: .center,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            // Foto del doctor
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 120, height: 120)
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                if let imageURL = doctor.imageURL, let url = URL(string: imageURL) {
                                    AsyncImage(url: url) { phase in
                                        if let image = phase.image {
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 120, height: 120)
                                                .clipShape(Circle())
                                        } else {
                                            Image(systemName: "person.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 60, height: 60)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                } else {
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(.gray)
                                }
                             
                            }
                            .offset(y: 100)
                        )
                }
                
                // Nombre del doctor y calificaciones
                VStack(spacing: 4) {
                    Text(doctor.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 70)
                    
                    Text(doctor.specialties)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    // Calificación
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.subheadline)
                        
                        Text(String(format: "%.1f", doctor.rating))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text("(\(doctor.reviewCount))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 4)
                }
                .padding(.bottom, 10)
                
                // Modificar el ScrollView para evitar que se regrese hacia arriba
                ScrollView(.vertical, showsIndicators: true) {
                    // Añadir un VStack principal con coordinateSpace para controlar mejor el scroll
                    VStack(spacing: 24) {
                        // Sección de información del doctor
                        VStack(spacing: 16) {
                            // Ubicación
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.title3)
                                
                                Text(doctor.ubicacion ?? "No hay ubicacionf")
                                    .font(.body)
                                
                                Spacer()
                            }
                            
                            // Disponibilidad
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.gray)
                                    .font(.title3)
                                
                                Text(doctor.availability.displayText)
                                    .font(.body)
                                
                                Spacer()
                            }
                            
                            // Modos de consulta
                            HStack(spacing: 10) {
                                ForEach(doctor.modes) { mode in
                                    Label(
                                        title: { Text(mode.rawValue).font(.body) },
                                        icon: {
                                            Image(systemName: mode == .online ? "video.fill" : "mappin.circle.fill")
                                                .foregroundColor(.indigo)
                                        }
                                    )
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color.indigo.opacity(0.1))
                                    .foregroundColor(.indigo)
                                    .cornerRadius(20)
                                }
                                
                                Spacer()
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        
                        // Sección Acerca de
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Descripcion")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(doctor.description ?? "No hay descripcion para este doctor")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal, 16)
                        
                        // Sección Agendar Cita
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Agendar Cita")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.bottom, 4)
                            
                            // Botones de mensaje y reserva
                            HStack(spacing: 15) {
                                // Botón de mensaje (solo si telefono no es nil)
                                if let telefono = doctor.telefono {
                                    Button(action: {
                                        // Abrir WhatsApp con el número de teléfono
                                        let whatsappURL = URL(string: "https://wa.me/\(telefono.replacingOccurrences(of: "+", with: "").replacingOccurrences(of: " ", with: ""))")!
                                        UIApplication.shared.open(whatsappURL)
                                    }) {
                                        HStack {
                                            Image(systemName: "message.fill")
                                                .font(.title3)
                                            Text("Mensaje")
                                                .font(.headline)
                                        }
                                        .padding(.vertical, 16)
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.indigo)
                                        .background(Color.white)
                                        .cornerRadius(30)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 30)
                                                .stroke(Color.indigo, lineWidth: 1)
                                        )
                                    }
                                }
                                
                                // Botón de agenda (solo si agenda no es nil)
                                if let agendaURL = doctor.agenda {
                                    Button(action: {
                                        // Abrir el enlace de la agenda
                                        let url = URL(string: agendaURL)!
                                        UIApplication.shared.open(url)
                                    }) {
                                        HStack {
                                            Image(systemName: "calendar.badge.plus")
                                                .font(.title3)
                                            Text("Agendar")
                                                .font(.headline)
                                        }
                                        .padding(.vertical, 16)
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.white)
                                        .background(Color.indigo)
                                        .cornerRadius(30)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                    .padding(.bottom, 100) // Añadir padding al final para permitir scroll completo
                }
                .coordinateSpace(name: "scrollView") // Identificador para el ScrollView
            }
            
            // Botón de regreso como overlay independiente
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(14)
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                    .padding(.top, 60)
                    .padding(.leading, 20)
                    
                    Spacer()
                }
                Spacer()
            }
            .zIndex(100) // Asegurar que esté por encima de todo
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        // Eliminar gestos que puedan estar interfiriendo con el scroll
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

struct DoctorsDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorsDetailView(doctor: Doctor.sampleDoctors[0])
    }
}
