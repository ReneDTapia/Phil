import SwiftUI

struct PictureView: View {
    @StateObject var viewModel = PictureViewModel(userID: TokenHelper.getUserID())
    var userID: Int
    @State private var isMonthYearSelected = false
    private let columns = [GridItem](repeating: .init(.flexible()), count: 4)
    var body: some View {
        
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            
                VStack(alignment: .leading) {
                    
                    Text("Mis fotos")
                        .font(.custom("Roboto Bold", size: 34))
                        .foregroundColor(Color.white)
                        .padding([.leading, .top])
                    Spacer()
                        .frame(height: 10)
                    HStack {
                        Button(action: { viewModel.previousMonth() }) {
                            Image(systemName: "chevron.left")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color(red: 0.42, green: 0.43, blue: 0.67))
                                .clipShape(Circle())
                        }

                        Spacer()

                        Text(monthYearFormatter.string(from: viewModel.currentDate))
                        .font(.custom("Roboto Bold", size: 32))
                        .foregroundColor(Color(.white))
                        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 4)
                        .onTapGesture {
                            isMonthYearSelected.toggle()
                        }
                        
                        

                        Spacer()

                        Button(action: { viewModel.nextMonth() }) {
                            Image(systemName: "chevron.right")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color(red: 0.42, green: 0.43, blue: 0.67))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                ScrollView {
                    ForEach(groupedPhotos(), id: \.key) { (date, photos) in
                      VStack {
                          Text(formatDateString(date))
                              .font(.custom("Roboto Thin Italic", size: 17))
                              .foregroundColor(Color.white)
                              .frame(maxWidth: .infinity, alignment: .leading)
                              .padding(.vertical, 5)
                              .padding(.leading)

                          LazyVGrid(columns: columns) {
                            ForEach(photos, id: \.id) { photo in
                                let base64String = photo.url
                                if let data = Data(base64Encoded: base64String),
                                let uiImage = UIImage(data: data) {

                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 82, height: 143)
                                        .cornerRadius(20)
                                        .clipped()

                                } else {
                                    Color.red
                                        .frame(width: 82, height: 143)
                                        .cornerRadius(20)
                                }
                            }
                        }
                      }
                    }
                }
            }
        }
        .overlay(
            
            isMonthYearSelected ? BottomRectangleView(date: $viewModel.currentDate) {
                isMonthYearSelected = false // Esto cierra la vista
            } : nil
        )
        .onAppear {
            viewModel.fetchPhotos(for: viewModel.currentDate)
        }
        .onReceive(viewModel.$currentDate) { newDate in
          viewModel.fetchPhotos(for: newDate)
        }
    }
    private func groupedPhotos() -> [(key: String, value: [Picture])] {
        let grouped = Dictionary(grouping: viewModel.photos, by: { $0.Date })
        return grouped.map { ($0.key, $0.value) }
               .sorted { $0.key > $1.key } // Ordenar por fecha, si es necesario
    }
    private func formatDateString(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd" // Asegúrate de que esto coincida con el formato de tu fecha en String
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "d 'de' MMM, yyyy"
            outputFormatter.locale = Locale(identifier: "es_ES") // Para obtener el mes en español
            return outputFormatter.string(from: date)
        } else {
            return dateString // Devuelve la cadena original si no se puede formatear
        }
    }
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM, yyyy"
        return formatter
    }
}

struct BottomRectangleView: View {
    @Binding var date: Date // Usa un Binding para actualizar la fecha
    let months = Calendar.current.monthSymbols.map { String($0.prefix(3)) } // Nombres abreviados de los meses
    var onClose: () -> Void

    var body: some View {
        ZStack{
            Color.black.opacity(0.50)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    onClose()
                }
            VStack {
                HStack {
                    Button(action: { changeYear(by: -1) }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 10)
                    
                    Spacer()
                    
                    Text(yearString(from: date))
                        .font(.custom("Roboto Thin", size: 23))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { changeYear(by: 1) }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 10)
                }
                .padding(.vertical, 10)
   
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4), spacing: 15) {
                  ForEach(months.indices, id: \.self) { index in
                      let month = months[index]
                      Button(action: { selectMonth(month) }) {
                          ZStack {
                              if currentMonthIndex() == index {
                                Circle()
                                    .fill(Color(red: 0.42, green: 0.43, blue: 0.67)) // Círculo completamente morado para el mes seleccionado
                              } else {
                                Circle()
                                    .fill(Color(red: 0.250980, green: 0.250980, blue: 0.250980)) // Color de fondo para los no seleccionados
                                    .overlay(
                                        Circle()
                                            .strokeBorder(Color.white, lineWidth: 1) // Delineado blanco para los no seleccionados
                                    )
                              }
                              
                              Text(month)
                                  .foregroundColor(.white)
                          }
                      }
                      .frame(width: 47, height: 47)
                  }
                }
                .padding(.bottom, 20)
                .padding(.horizontal, 45)
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.black))
                    // Añadir un borde blanco alrededor del rectángulo
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 50)
           
        }
        
    }
    private func changeYear(by amount: Int) {
        if let newDate = Calendar.current.date(byAdding: .year, value: amount, to: date) {
            date = newDate
        }
    }
    private func currentMonthIndex() -> Int {
      let calendar = Calendar.current
      return calendar.component(.month, from: date) - 1 // Los meses están indexados a partir de 1
    }
    private func selectMonth(_ month: String) {
        if let monthIndex = months.firstIndex(of: month) {
            var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
            components.month = monthIndex + 1

            // Asegúrate de mantener el mismo año
            if let newDate = Calendar.current.date(from: components) {
                date = newDate
            }
        }
        onClose()
    }
    private func yearString(from date: Date) -> String {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy" // Formato que solo muestra el año
      return formatter.string(from: date)
    }
}

struct PictureView_Previews: PreviewProvider {
    static var previews: some View {
        PictureView(userID :  TokenHelper.getUserID() ?? 0)
    }
}
