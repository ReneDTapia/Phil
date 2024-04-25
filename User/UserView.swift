import SwiftUI

struct UserView: View {
    @ObservedObject var viewModel = UserViewModel(userId : 0)
    @State private var editableUsername: String = ""
    @Environment(\.presentationMode) var presentationMode
    let userId: Int
    init(userId: Int) {
        self.userId = userId
        self.viewModel = UserViewModel(userId: userId)
    }
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 0) {
                GeometryReader { geometry in
                    ZStack {
                        
                        
                        // Fondo Morado con Curvas
                        Path { path in
                            let width = geometry.size.width
                            let height = geometry.size.height * 1
                            path.move(to: CGPoint(x: 0, y: 0))
                            path.addLine(to: CGPoint(x: width, y: 0))
                            path.addLine(to: CGPoint(x: width, y: height))
                            path.addQuadCurve(to: CGPoint(x: 0, y: height),
                                              control: CGPoint(x: width / 2, y: height + 60))
                        }
                        .fill(.indigo)
                        .edgesIgnoringSafeArea(.top)
                        
                        
                        // Círculo Blanco en la Parte Morada
                        
                        ZStack {
                            
                            Ellipse()
                                .strokeBorder(Color.white, lineWidth: 10)
                            
                            
                        }
                        .frame(width: 167, height: 165)
                        .position(x: geometry.size.width / 2, y: geometry.size.height * 0.35)
                        Image("person-placeholder")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150) // ajusta el tamaño de la imagen según sea necesario
                            .clipShape(Ellipse())
                            .overlay(Ellipse().stroke(Color.white, lineWidth: 4))
                            .frame(width: 167, height: 165)
                            .position(x: geometry.size.width / 2, y: geometry.size.height * 0.35)
                        
                        Text(viewModel.user?.username ?? "")
                            .font(.largeTitle)
                        
                            .fontWeight(.bold)
                            .position(x: geometry.size.width / 2, y: geometry.size.height * 0.5)
                            .padding(.top,75)
                            .foregroundColor(.white)
                    }
                }
                .frame(height: UIScreen.main.bounds.height * 0.4)
                
                HStack {
                    UserInfoRow(label: "Usuario:", value: $editableUsername, spacing: 10, isEditable: true)
                    Spacer()
                }
                .padding([.leading, .trailing], 30)
                .padding(.top, 30)
                
                HStack {
                    UserInfoRow(label: "Correo:", value: .constant(viewModel.user?.email ?? ""), spacing: 10, isEditable: false)
                    Spacer()
                }
                .padding([.leading, .trailing], 30)
                .padding(.top, 17)
                
                
                Spacer()
                
                // Botón en la Parte Inferior
                Button(action: {
                    viewModel.updateUsername(newUsername: editableUsername)
                }) {
                    Text("Guardar")
                    
                        .foregroundColor(.white)
                        .font(.title2)
                        .bold()
                        .frame(width: 130)
                        .padding()
                        .padding(.vertical,5)
                        .background(.indigo)
                        .cornerRadius(130)
                        }
                .padding()
            }.gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width > 100 {  // Comprobar deslizamiento hacia la izquierda
                            withAnimation {
                                presentationMode.wrappedValue.dismiss()  // Cerrar la vista
                            }
                        }
                    }
            )
            .overlay(
                // Botón con Icono SF Symbols
                HStack{
                    Button(action: {
                        withAnimation {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {HStack{
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                        
                        Text("Regresar")
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                        Spacer()
                        
                        NavigationLink(destination: MoreOptions(userId: userId)){
                            Image(systemName:"doc")
                                .foregroundColor(.white)
                        }
                        
                }
                .padding(.leading, 20)
                    
                .padding(.trailing, 20)
                    
            }
                
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                , alignment: .topLeading
            )
            .onAppear {
                viewModel.fetchUserInfo()
            }
            .onReceive(viewModel.$user){ user in
                self.editableUsername = user?.username ?? ""
            }
        }
            .navigationBarBackButtonHidden(true)
    }
}

struct UserInfoRow: View {
    var label: String
    @Binding var value: String
    var spacing: CGFloat
    var isEditable: Bool
    @FocusState private var isInputActive: Bool
    @State private var isEditing = false

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            HStack {
                Text(label)
                    .font(.headline)
                    .foregroundColor(.gray)

                Spacer()

                if isEditable {
                    Button(action: {
                        isEditing.toggle()
                    }) {
                        Image(systemName: "pencil.circle")
                            .foregroundColor(.indigo)
                            .font(.system(size: 35))
                    }
                    .offset(y: 36)
                }
            }
            .padding(.leading, 30)

            if isEditable && isEditing {
                TextField("", text: $value)
                    .focused($isInputActive)
                    .font(.title2)
                    .padding(.leading, 30)
                    .onAppear {
                        self.isInputActive = true
                    }
            } else {
                Text(value)
                    .font(.title2)
                    .padding(.leading, 30)
            }

            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(hex: "CBCBCB"))
                .padding(.leading, 30)
        }
        .padding(.bottom, 5)
    }
}

// ... (Color extension remains the same)

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView(userId: 37)
    }
}
