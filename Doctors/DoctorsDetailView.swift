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
    @State private var selectedDay: String = "Today"
    @State private var selectedTime: String?
    
    let availableDays = ["Today", "Tomorrow", "Wed", "Thu", "Fri"]
    let availableTimes = ["9:00 AM", "10:30 AM", "1:00 PM", "2:30 PM", "4:00 PM", "5:30 PM"]
    
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
                                
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.gray)
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Sección de información del doctor
                        VStack(spacing: 16) {
                            // Ubicación
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.title3)
                                
                                Text("New York, NY")
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
                            Text("About")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Dr. Sarah specializes in Anxiety & Depression and has helped hundreds of patients overcome their challenges. With a patient-centered approach, they create a safe and supportive environment for healing and growth.")
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
                        
                        // Sección Citas disponibles
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Available Appointments")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.bottom, 4)
                            
                            // Selector de días
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(availableDays, id: \.self) { day in
                                        Text(day)
                                            .fontWeight(selectedDay == day ? .bold : .regular)
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 20)
                                            .background(selectedDay == day ? Color.indigo : Color.gray.opacity(0.1))
                                            .foregroundColor(selectedDay == day ? .white : .primary)
                                            .cornerRadius(30)
                                            .onTapGesture {
                                                selectedDay = day
                                                selectedTime = nil
                                            }
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                            
                            Divider()
                                .padding(.vertical, 8)
                            
                            // Selector de horas
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                ForEach(availableTimes, id: \.self) { time in
                                    Text(time)
                                        .font(.body)
                                        .fontWeight(selectedTime == time ? .semibold : .regular)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 15)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedTime == time ? Color.indigo : Color.gray.opacity(0.3), lineWidth: 1)
                                                .background(selectedTime == time ? Color.indigo.opacity(0.05) : Color.white)
                                        )
                                        .cornerRadius(12)
                                        .onTapGesture {
                                            selectedTime = time
                                        }
                                }
                            }
                            
                            // Botones de mensaje y reserva
                            HStack(spacing: 15) {
                                // Botón de mensaje
                                Button(action: {
                                    // Acción para enviar mensaje
                                }) {
                                    HStack {
                                        Image(systemName: "message.fill")
                                            .font(.title3)
                                        Text("Message")
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
                                
                                // Botón de reserva
                                Button(action: {
                                    // Acción para reservar
                                }) {
                                    HStack {
                                        Image(systemName: "calendar.badge.plus")
                                            .font(.title3)
                                        Text("Book")
                                            .font(.headline)
                                    }
                                    .padding(.vertical, 16)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                                    .background(Color.indigo)
                                    .cornerRadius(30)
                                }
                            }
                            .padding(.top, 24)
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                }
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
    }
}

struct DoctorsDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorsDetailView(doctor: Doctor.sampleDoctors[0])
    }
} 
