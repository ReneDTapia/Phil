import SwiftUI

struct UserView: View {
    @ObservedObject var viewModel: UserViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var editableUsername: String = ""
    @State private var showingErrorAlert = false
    
    let userId: Int
    
    init(userId: Int) {
        self.userId = userId
        self._viewModel = ObservedObject(wrappedValue: UserViewModel(userId: userId))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Profile Header
                        HStack(alignment: .center, spacing: 20) {
                            // Avatar
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
                                
                                Text(getInitials(from: viewModel.userStats?.username ?? ""))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            // Stats
                            VStack(alignment: .leading, spacing: 8) {
                                Text(viewModel.userStats?.username ?? "")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("\(viewModel.userStats?.totalTopicsCompleted ?? 0) temas completados")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                        
                        // Categories Grid
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Categorías Completadas")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                ForEach(viewModel.userStats?.completedCategories ?? []) { category in
                                    CategoryBadge(category: category)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Stats Cards
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Estadísticas por Categoría")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.userStats?.categoriesStats ?? []) { stat in
                                StatCard(stat: stat)
                            }
                        }
                        .padding(.bottom, 80) // Añadir padding en la parte inferior para el botón flotante
                    }
                }
                
                // Botón flotante de MoreOptions
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: MoreOptions()) {
                            ZStack {
                                Circle()
                                    .fill(Color.indigo)
                                    .frame(width: 56, height: 56)
                                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                                
                                Image(systemName: "star.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 24))
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.indigo)
                            Text("Regresar")
                                .foregroundColor(.indigo)
                                .font(.body)
                        }
                    }
                }
            }
            .onAppear {
                viewModel.fetchUserInfo()
            }
        }
        .navigationBarBackButtonHidden(true)
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
}

// El resto del código permanece igual...
struct CategoryBadge: View {
    let category: CategoryInfo
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(category.color).opacity(0.2))
                    .frame(width: 70, height: 70)
                
                Text(category.emoji ?? "📚")
                    .font(.system(size: 30))
            }
            
            Text(category.name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
}

struct StatCard: View {
    let stat: StatsByCategory
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(stat.category.color).opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Text(stat.category.emoji ?? "📚")
                    .font(.system(size: 24))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(stat.category.name)
                    .font(.headline)
                Text("\(stat.topicsCompleted) temas completados")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(stat.topicsCompleted)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color(stat.category.color))
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

extension Color {
    init(_ colorName: String) {
        switch colorName.lowercased() {
        case "pink":
            self = Color.pink
        case "blue":
            self = Color.blue
        case "orange":
            self = Color.orange
        case "cyan":
            self = Color.cyan
        case "red":
            self = Color.red
        case "purple":
            self = Color.purple
        case "green":
            self = Color.green
        case "light blue":
            self = Color(red: 0.5, green: 0.8, blue: 1.0)
        default:
            self = .gray
        }
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView(userId: 8)
    }
}
