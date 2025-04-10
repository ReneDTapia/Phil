import SwiftUI

struct PrivacyView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Privacy Policy Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Política de Privacidad")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    PrivacyInfoCard(
                        title: "Introducción",
                        description: "En Phil, valoramos y respetamos tu privacidad. Esta política explica cómo recopilamos, usamos y protegemos tu información personal cuando utilizas nuestra aplicación."
                    )
                    
                    PrivacyInfoCard(
                        title: "Información que Recopilamos",
                        description: "Recopilamos información que nos proporcionas directamente, como tu nombre, correo electrónico y preferencias de bienestar mental. También recopilamos datos de uso de la aplicación para mejorar tu experiencia."
                    )
                    
                    PrivacyInfoCard(
                        title: "Uso de la Información",
                        description: "Utilizamos tu información para:\n\n• Personalizar tu experiencia en la aplicación\n• Proporcionar contenido relevante sobre bienestar mental\n• Mejorar nuestros servicios y funcionalidades\n• Responder a tus consultas y solicitudes\n• Enviar actualizaciones importantes sobre la aplicación"
                    )
                    
                    PrivacyInfoCard(
                        title: "Protección de Datos",
                        description: "Implementamos medidas de seguridad técnicas y organizativas para proteger tu información personal. Utilizamos encriptación y protocolos de seguridad estándar de la industria para mantener tus datos seguros."
                    )
                    
                    PrivacyInfoCard(
                        title: "Tus Derechos",
                        description: "Tienes derecho a:\n\n• Acceder a tus datos personales\n• Solicitar la corrección de datos inexactos\n• Solicitar la eliminación de tus datos\n• Oponerte al procesamiento de tus datos\n• Solicitar la portabilidad de tus datos"
                    )
                    
                    PrivacyInfoCard(
                        title: "Contacto",
                        description: "Si tienes preguntas sobre esta política de privacidad o sobre cómo manejamos tus datos, puedes contactarnos en:\n\nsupport@philapp.com"
                    )
                }
                .padding()
                
                Text("Última actualización: 15 de marzo de 2024")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding()
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("Privacidad")
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
    }
}

struct PrivacyInfoCard: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.indigo)
            
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

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PrivacyView()
        }
    }
} 