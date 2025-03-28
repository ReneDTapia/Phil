import SwiftUI
import Charts

struct UserView: View {
    @StateObject private var viewModel: UserViewModel
    @State private var editableUsername: String = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTimeframe: Timeframe = .week
    
    init(userId: Int) {
        self._viewModel = StateObject(wrappedValue: UserViewModel(userId: userId))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Sección Superior - Perfil estilo Instagram
                        HStack(alignment: .center, spacing: 15) {
                            // Avatar con iniciales
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [Color.pink, Color.orange]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(Color.blue, lineWidth: 3)
                                    )
                                
                                Text(getInitials(from: viewModel.user?.username ?? "JD"))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding(.leading, -30) // Mueve la imagen más a la izquierda
                            
                            Spacer()
                                .frame(width: 30)
                            
                            // Estadísticas en horizontal
                            HStack(spacing: 40) {
                                // Sessions
                                VStack(spacing: 4) {
                                    Text("\(viewModel.sessionsCount)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Text("Sessions")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                // Streak
                                VStack(spacing: 4) {
                                    Text("\(viewModel.streakCount)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Text("Streak")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                // Hours
                                VStack(spacing: 4) {
                                    Text("\(viewModel.hoursCount)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Text("Hours")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        // Información del perfil
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.user?.username ?? "John Doe")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Text(viewModel.user?.bio ?? "Mental health enthusiast | Mindfulness practitioner")
                                .font(.subheadline)
                            
                            Text(viewModel.user?.goal ?? "Working on reducing anxiety and improving sleep 💪")
                                .font(.subheadline)
                                .padding(.top, 2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        
                        // Botones de acción
                        HStack(spacing: 15) {
                            Button(action: {
                                // Acción para editar perfil
                            }) {
                                Text("Edit Profile")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                                    .background(Color(red: 0.3, green: 0.3, blue: 0.8)) // Color matching depression
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                // Acción para compartir progreso
                            }) {
                                Text("Share Progress")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                                    .background(Color(red: 0.6, green: 0.2, blue: 0.8)) // Color matching anxiety
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Categorías con emojis - Ahora con 4 categorías
                        HStack(spacing: 15) {
                            CategoryIcon(emoji: "😞", label: "Depresión", color: WellnessCategory.depression.color)
                            CategoryIcon(emoji: "😨", label: "Ansiedad", color: WellnessCategory.anxiety.color)
                            CategoryIcon(emoji: "💑", label: "Relaciones", color: WellnessCategory.relationships.color)
                            CategoryIcon(emoji: "😌", label: "Bienestar", color: WellnessCategory.wellbeing.color)
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 10)
                        
                        // Línea divisoria
                        Divider()
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                        
                        // Sección de gráficos de bienestar - Con tarjeta
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            
                            VStack(alignment: .leading, spacing: 20) {
                                // Título con selector de tiempo
                                HStack {
                                    Text("Your Wellness Journey")
                                        .font(.title3)
                                        .fontWeight(.bold)
                
                                    Spacer()
                
                                    TimeframeSelector(selectedTimeframe: $selectedTimeframe, viewModel: viewModel)
                                }
                                
                                // Gráfico actualizado para mostrar las tres categorías de bienestar
                                Chart {
                                    ForEach(viewModel.wellnessData) { item in
                                        BarMark(
                                            x: .value("Day", item.label),
                                            y: .value("Value", item.value)
                                        )
                                        .foregroundStyle(item.category.color)
                                    }
                                }
                                .frame(height: 200)
                                
                                // Leyenda del gráfico con las cuatro categorías en una sola línea
                                HStack(spacing: 8) {
                                    // Depresión
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(WellnessCategory.depression.color)
                                            .frame(width: 8, height: 8)
                                        Text(WellnessCategory.depression.name)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                        .frame(width: 3)
                                    
                                    // Ansiedad
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(WellnessCategory.anxiety.color)
                                            .frame(width: 8, height: 8)
                                        Text(WellnessCategory.anxiety.name)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                        .frame(width: 3)
                                    
                                    // Relaciones
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(WellnessCategory.relationships.color)
                                            .frame(width: 8, height: 8)
                                        Text(WellnessCategory.relationships.name)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                        .frame(width: 3)
                                    
                                    // Bienestar
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(WellnessCategory.wellbeing.color)
                                            .frame(width: 8, height: 8)
                                        Text(WellnessCategory.wellbeing.name)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.top, 5)
                            }
                            .padding(20)
                        }
                        .padding(.horizontal)
                        
                        // Sección de Logros
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Your Achievements")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            // Tarjetas de logros
                            ForEach(viewModel.achievements) { achievement in
                                AchievementCard(achievement: achievement)
                            }
                        }
                        .padding(.top, 10)
                    }
                    .padding(.vertical)
                }
                .onAppear {
                    viewModel.fetchUserInfo()
                    viewModel.fetchUserStats()
                    viewModel.fetchAchievements()
                    viewModel.updateTimeframe(.week)
                }
                .navigationBarHidden(true)
                
                // Overlay de carga
                if viewModel.isLoading {
                    LoadingView()
                }
                
                // Mensaje de error
                if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage) {
                        // Reintentar carga
                        viewModel.fetchUserInfo()
                        viewModel.fetchUserStats()
                        viewModel.fetchAchievements()
                    }
                }
            }
        }
    }
    
    // Función para obtener iniciales del nombre de usuario
    private func getInitials(from name: String) -> String {
        let components = name.components(separatedBy: " ")
        if components.count > 1, 
           let first = components.first?.first,
           let last = components.last?.first {
            return "\(first)\(last)".uppercased()
        } else if let first = name.first {
            return String(first).uppercased()
        }
        return "JD"
    }
}

// Componente para los iconos de categoría
struct CategoryIcon: View {
    let emoji: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(color, lineWidth: 2)
                    .frame(width: 70, height: 70)
                
                Text(emoji)
                    .font(.system(size: 30))
            }
            
            Text(label)
                .font(.footnote)
                .padding(.top, 5)
        }
    }
}

// Selector de marco de tiempo
struct TimeframeSelector: View {
    @Binding var selectedTimeframe: Timeframe
    @ObservedObject var viewModel: UserViewModel
    
    var body: some View {
        HStack {
            Button(action: { 
                selectedTimeframe = .week
                viewModel.updateTimeframe(.week)
            }) {
                Text("Week")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(selectedTimeframe == .week ? Color(red: 0.5, green: 0.3, blue: 0.7) : Color.clear)
                    .foregroundColor(selectedTimeframe == .week ? .white : .primary)
                    .cornerRadius(20)
            }
            
            Button(action: { 
                selectedTimeframe = .month
                viewModel.updateTimeframe(.month)
            }) {
                Text("Month")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(selectedTimeframe == .month ? Color(red: 0.5, green: 0.3, blue: 0.7) : Color.clear)
                    .foregroundColor(selectedTimeframe == .month ? .white : .primary)
                    .cornerRadius(20)
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}

// Componente de tarjeta de logro
struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            HStack(spacing: 15) {
                // Icono del logro
                ZStack {
                    Circle()
                        .fill(Color(.systemGray6))
                        .frame(width: 60, height: 60)
                    
                    Text(achievement.emoji)
                        .font(.system(size: 30))
                }
                
                // Información del logro
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(achievement.title)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(Int(achievement.progressPercent))%")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(achievement.progressPercent == 100 ? .green : .indigo)
                    }
                    
                    Text(achievement.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Barra de progreso
                    ProgressView(value: achievement.progressPercent, total: 100)
                        .progressViewStyle(LinearProgressViewStyle(tint: .indigo))
                        .padding(.top, 5)
                }
            }
            .padding(15)
        }
        .padding(.horizontal)
        .padding(.bottom, 5)
    }
}

// Componente para mostrar indicador de carga
struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("Cargando datos...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(25)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(red: 0.5, green: 0.3, blue: 0.7).opacity(0.8))
            )
        }
    }
}

// Componente para mostrar errores
struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
            
            VStack(spacing: 15) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Text("Error")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                
                Button(action: retryAction) {
                    Text("Reintentar")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                        .background(Color.purple)
                        .cornerRadius(10)
                }
                .padding(.top, 5)
            }
            .padding(25)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.red.opacity(0.75))
            )
            .padding(.horizontal, 40)
        }
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView(userId: 37)
    }
} 
