import SwiftUI
import UserNotifications

struct NotificationsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = NotificationsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    Text("Notificaciones")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Configura cómo Phil te mantiene informado sobre tu bienestar mental.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Main Toggle
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Permitir Notificaciones")
                                .font(.headline)
                            
                            Text("Activa o desactiva todas las notificaciones de Phil")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $viewModel.allowNotifications)
                            .labelsHidden()
                            .onChange(of: viewModel.allowNotifications) { newValue in
                                viewModel.toggleNotifications(enabled: newValue)
                            }
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                }
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // Notification Types
                if viewModel.allowNotifications {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tipos de Notificaciones")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            NotificationToggleRow(
                                title: "Recordatorios Diarios", 
                                description: "Recordatorios para realizar actividades de bienestar",
                                isOn: $viewModel.dailyReminders
                            )
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            NotificationToggleRow(
                                title: "Nuevos Contenidos", 
                                description: "Alertas sobre nuevos artículos y cursos",
                                isOn: $viewModel.newContentAlerts
                            )
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            NotificationToggleRow(
                                title: "Mensajes Motivacionales", 
                                description: "Frases y consejos para mantener tu motivación",
                                isOn: $viewModel.motivationalMessages
                            )
                        }
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    // Scheduled Notifications
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Horario")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            // Do Not Disturb
                            NotificationToggleRow(
                                title: "No Molestar", 
                                description: "Silenciar notificaciones durante horas seleccionadas",
                                isOn: $viewModel.doNotDisturb
                            )
                            
                            // Time Range (only if doNotDisturb is on)
                            if viewModel.doNotDisturb {
                                Divider()
                                    .padding(.leading, 16)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Horas de Silencio")
                                        .font(.headline)
                                    
                                    HStack {
                                        Text("Desde")
                                            .foregroundColor(.secondary)
                                        
                                        DatePicker("", selection: $viewModel.quietHoursStart, displayedComponents: .hourAndMinute)
                                            .labelsHidden()
                                        
                                        Text("Hasta")
                                            .foregroundColor(.secondary)
                                        
                                        DatePicker("", selection: $viewModel.quietHoursEnd, displayedComponents: .hourAndMinute)
                                            .labelsHidden()
                                    }
                                }
                                .padding()
                            }
                        }
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    // Save Button
                    Button(action: {
                        viewModel.saveSettings()
                        viewModel.scheduleNotifications()
                    }) {
                        Text("Guardar Configuración")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.indigo)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                
                // Status Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: viewModel.permissionGranted ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                            .foregroundColor(viewModel.permissionGranted ? .green : .orange)
                        
                        Text(viewModel.permissionGranted ? 
                            "Permisos de notificación concedidos" : 
                            "Permisos de notificación no concedidos")
                            .font(.subheadline)
                            .foregroundColor(viewModel.permissionGranted ? .green : .orange)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
            .onAppear {
                viewModel.checkNotificationStatus()
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("Notificaciones")
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
        .navigationBarBackButtonHidden(true)
    }
}

struct NotificationToggleRow: View {
    let title: String
    let description: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}

class NotificationsViewModel: ObservableObject {
    @Published var allowNotifications = false
    @Published var permissionGranted = false
    
    @Published var dailyReminders = true
    @Published var newContentAlerts = true
    @Published var motivationalMessages = true
    
    @Published var doNotDisturb = false
    @Published var quietHoursStart = Calendar.current.date(from: DateComponents(hour: 22, minute: 0)) ?? Date()
    @Published var quietHoursEnd = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
    
    private let userDefaults = UserDefaults.standard
    private let notificationCenter = UNUserNotificationCenter.current()
    
    init() {
        loadSettings()
    }
    
    func checkNotificationStatus() {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.permissionGranted = settings.authorizationStatus == .authorized
                self.allowNotifications = self.permissionGranted
            }
        }
    }
    
    func toggleNotifications(enabled: Bool) {
        if enabled {
            requestNotificationPermission()
        } else {
            // No need to do anything if toggling off, just update the state
        }
    }
    
    private func requestNotificationPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.permissionGranted = granted
                if !granted {
                    // If permission denied, update the UI accordingly
                    self.allowNotifications = false
                }
            }
        }
    }
    
    func saveSettings() {
        userDefaults.set(allowNotifications, forKey: "allowNotifications")
        userDefaults.set(dailyReminders, forKey: "dailyReminders")
        userDefaults.set(newContentAlerts, forKey: "newContentAlerts")
        userDefaults.set(motivationalMessages, forKey: "motivationalMessages")
        userDefaults.set(doNotDisturb, forKey: "doNotDisturb")
        userDefaults.set(quietHoursStart, forKey: "quietHoursStart")
        userDefaults.set(quietHoursEnd, forKey: "quietHoursEnd")
    }
    
    private func loadSettings() {
        allowNotifications = userDefaults.bool(forKey: "allowNotifications")
        dailyReminders = userDefaults.bool(forKey: "dailyReminders")
        newContentAlerts = userDefaults.bool(forKey: "newContentAlerts")
        motivationalMessages = userDefaults.bool(forKey: "motivationalMessages")
        doNotDisturb = userDefaults.bool(forKey: "doNotDisturb")
        
        if let start = userDefaults.object(forKey: "quietHoursStart") as? Date {
            quietHoursStart = start
        }
        
        if let end = userDefaults.object(forKey: "quietHoursEnd") as? Date {
            quietHoursEnd = end
        }
    }
    
    func scheduleNotifications() {
        // Remove any existing scheduled notifications
        notificationCenter.removeAllPendingNotificationRequests()
        
        // Only schedule if notifications are allowed
        guard allowNotifications && permissionGranted else { return }
        
        // Schedule daily reminders
        if dailyReminders {
            scheduleDailyReminders()
        }
        
        // Schedule motivational messages
        if motivationalMessages {
            scheduleMotivationalMessages()
        }
    }
    
    private func scheduleDailyReminders() {
        let messages = [
            "No olvides tu práctica de atención plena hoy",
            "¿Has completado tu ejercicio de respiración hoy?",
            "Recuerda tomar un momento para ti mismo hoy",
            "Es hora de tu momento de reflexión diario"
        ]
        
        let content = UNMutableNotificationContent()
        content.title = "Recordatorio Diario"
        content.body = messages.randomElement() ?? messages[0]
        content.sound = UNNotificationSound.default
        
        // Create a time-based trigger that repeats daily
        var dateComponents = DateComponents()
        dateComponents.hour = 9 // 9am
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        notificationCenter.add(request)
    }
    
    private func scheduleMotivationalMessages() {
        let messages = [
            "Cada pequeño paso cuenta en tu viaje de bienestar",
            "Tu salud mental importa. Tómate un momento para respirar",
            "Recuerda ser amable contigo mismo hoy",
            "El autocuidado no es egoísmo, es necesario"
        ]
        
        let content = UNMutableNotificationContent()
        content.title = "Mensaje Motivacional"
        content.body = messages.randomElement() ?? messages[0]
        content.sound = UNNotificationSound.default
        
        // Create a time-based trigger that repeats daily in the afternoon
        var dateComponents = DateComponents()
        dateComponents.hour = 16 // 4pm
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "motivationalMessage", content: content, trigger: trigger)
        
        notificationCenter.add(request)
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NotificationsView()
        }
    }
} 