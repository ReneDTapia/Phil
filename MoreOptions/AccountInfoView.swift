import SwiftUI
import Alamofire
import KeychainSwift

struct AccountInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var editingUsername: Bool = false
    @State private var newUsername: String = ""
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var isLoading: Bool = false
    @State private var showLogoutConfirmation: Bool = false
    @State private var navigateToLogin: Bool = false
    @StateObject private var loginViewModel = LoginViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    Text("Información de la Cuenta")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    // Avatar placeholder
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [.purple, .indigo]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 3)
                                        .shadow(color: .black.opacity(0.2), radius: 4)
                                )
                            
                            Text(getInitials(from: username))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 20)
                }
                
                // Información del usuario
                VStack(alignment: .leading, spacing: 0) {
                    // Nombre de usuario
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nombre de Usuario")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        HStack {
                            if editingUsername {
                                TextField("Nombre de usuario", text: $newUsername)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .padding(.leading)
                                
                                Button(action: {
                                    editingUsername = false
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing)
                                }
                                
                                Button(action: {
                                    updateUsername()
                                }) {
                                    Text("Guardar")
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.indigo)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                        .padding(.trailing)
                                }
                                .disabled(isLoading)
                            } else {
                                Text(username)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .padding(.leading)
                                
                                Button(action: {
                                    newUsername = username
                                    editingUsername = true
                                }) {
                                    Text("Editar")
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.indigo)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                        .padding(.trailing)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Correo electrónico
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Correo Electrónico")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Text(email)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // Botón para cerrar sesión
                Button(action: {
                    showLogoutConfirmation = true
                }) {
                    Text("Cerrar Sesión")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
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
        .onAppear {
            fetchUserInfo()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .confirmationDialog(
            "¿Estás seguro que deseas cerrar sesión?",
            isPresented: $showLogoutConfirmation,
            titleVisibility: .visible
        ) {
            Button("Cerrar Sesión", role: .destructive) {
                logout()
            }
            Button("Cancelar", role: .cancel) {}
        }
        // Navegación programática a la vista de inicio de sesión
        .fullScreenCover(isPresented: $navigateToLogin) {
            UsernameView(viewModel: loginViewModel)
        }
    }
    
    private func fetchUserInfo() {
        guard let userId = TokenHelper.getUserID() else {
            alertTitle = "Error"
            alertMessage = "No se pudo obtener la información del usuario"
            showAlert = true
            return
        }
        
        isLoading = true
        
        APIClient.getN(path: "GetUsersInfo/\(userId)") { (result: Result<UserInfo, AFError>) in
            let updateUI = {
                self.isLoading = false
                
                switch result {
                case .success(let userInfo):
                    self.username = userInfo.username
                    self.email = userInfo.email
                case .failure(let error):
                    self.alertTitle = "Error"
                    self.alertMessage = "No se pudo cargar la información: \(error.localizedDescription)"
                    self.showAlert = true
                }
            }
            
            DispatchQueue.main.async(execute: updateUI)
        }
    }
    
    private func updateUsername() {
        guard let userId = TokenHelper.getUserID() else {
            alertTitle = "Error"
            alertMessage = "No se pudo obtener la información del usuario"
            showAlert = true
            return
        }
        
        // Validar que el nuevo nombre de usuario no esté vacío
        if newUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertTitle = "Error"
            alertMessage = "El nombre de usuario no puede estar vacío"
            showAlert = true
            return
        }
        
        // Si el nombre de usuario no cambió, no hacer nada
        if newUsername == username {
            editingUsername = false
            return
        }
        
        isLoading = true
        
        let parameters: [String: Any] = ["newUsername": newUsername]
        
        APIClient.putN(path: "PutUsername/\(userId)", parameters: parameters) { (result: Result<EmptyResponse, AFError>) in
            let updateUI = {
                self.isLoading = false
                
                switch result {
                case .success:
                    self.username = self.newUsername
                    self.editingUsername = false
                    self.alertTitle = "Éxito"
                    self.alertMessage = "Nombre de usuario actualizado correctamente"
                    self.showAlert = true
                case .failure(let error):
                    // Simplificar el manejo de errores para mostrar solo el mensaje genérico
                    self.alertTitle = "Error"
                    self.alertMessage = "No se pudo actualizar el nombre de usuario: \(error.localizedDescription)"
                    self.showAlert = true
                }
            }
            
            DispatchQueue.main.async(execute: updateUI)
        }
    }
    
    private func getInitials(from name: String) -> String {
        let components = name.components(separatedBy: " ")
        if components.count > 1,
           let first = components.first?.first,
           let last = components.last?.first {
            return "\(first)\(last)".uppercased()
        } else if let first = name.first {
            return String(first).uppercased()
        }
        return "U"
    }
    
    // Función para cerrar sesión
    private func logout() {
        // Eliminar el token utilizando AuthService y LoginViewModel
        loginViewModel.logout()
        
        // Mostrar un mensaje de éxito
        alertTitle = "Sesión cerrada"
        alertMessage = "Has cerrado sesión correctamente"
        showAlert = true
        
        // Navegar a la pantalla de inicio de sesión
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.navigateToLogin = true
        }
    }
}

// Estructura para decodificar la respuesta del API
struct UserInfo: Codable {
    let username: String
    let email: String
}

// Estructura para decodificar errores del API
struct ErrorResponse: Codable {
    let error: String
}

// Estructura vacía para respuestas sin datos
struct EmptyResponse: Codable {}

struct AccountInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AccountInfoView()
        }
    }
} 