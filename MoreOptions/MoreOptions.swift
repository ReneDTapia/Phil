import SwiftUI

struct MoreOptions: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // About Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Acerca de Phil")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        InfoCard(
                            icon: "brain.head.profile",
                            title: "Bienestar Mental",
                            description: "Phil es una aplicación diseñada para apoyar el bienestar mental y emocional de sus usuarios."
                        )
                        
                        InfoCard(
                            icon: "book.fill",
                            title: "Recursos Educativos",
                            description: "Amplia gama de recursos sobre salud mental, incluyendo artículos y videos sobre manejo del estrés, ansiedad, depresión, autoestima y más."
                        )
                        
                        InfoCard(
                            icon: "message.and.waveform.fill",
                            title: "Asistente 24/7",
                            description: "Chatbot inteligente disponible las 24 horas para brindar apoyo emocional y consejos personalizados."
                        )
                    }
                    .padding()
                    
                    // Settings Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Configuración")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            NavigationLink(destination: Text("Información de la Cuenta")) {
                                SettingsRow(icon: "person.fill", title: "Información de la Cuenta", color: .blue)
                            }
                            
                            NavigationLink(destination: Text("Notificaciones")) {
                                SettingsRow(icon: "bell.fill", title: "Notificaciones", color: .purple)
                            }
                            
                            NavigationLink(destination: Text("Privacidad")) {
                                SettingsRow(icon: "lock.fill", title: "Privacidad", color: .green)
                            }
                            
                            Button(action: {
                                showingDeleteAlert = true
                            }) {
                                SettingsRow(icon: "trash.fill", title: "Eliminar Cuenta", color: .red)
                            }
                        }
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle("Más Información")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Regresar")
                                .font(.body)
                        }
                        .foregroundColor(.indigo)
                    }
                }
            }
            .alert("Eliminar Cuenta", isPresented: $showingDeleteAlert) {
                Button("Cancelar", role: .cancel) {}
                Button("Eliminar", role: .destructive) {
                    // Aquí iría la lógica para eliminar la cuenta
                }
            } message: {
                Text("¿Estás seguro que deseas eliminar tu cuenta? Esta acción no se puede deshacer.")
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.indigo)
                    .frame(width: 32, height: 32)
                
                Text(title)
                    .font(.headline)
            }
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            Text(title)
                .foregroundColor(title == "Eliminar Cuenta" ? .red : .primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(.systemGray3))
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}

struct MoreOptions_Previews: PreviewProvider {
    static var previews: some View {
        MoreOptions()
    }
}
