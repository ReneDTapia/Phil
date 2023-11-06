import SwiftUI

struct Day: Identifiable {
    let id = UUID()
    let date: Date
}

struct DayView: View {
    var day: Day
    @Binding var selectedDate: Date // Nuevo binding para manejar la fecha seleccionada

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18.39)
                .fill(isSelected ? Color(red: 0.3725, green: 0.8588, blue: 0.9255) : Color(#colorLiteral(red: 0.8117647171020508, green: 0.8549019694328308, blue: 0.929411768913269, alpha: 1)))

            RoundedRectangle(cornerRadius: 18.39)
                .strokeBorder(Color(#colorLiteral(red: 0.41960784792900085, green: 0.4313725531101227, blue: 0.6705882549285889, alpha: 1)), lineWidth: 4.5973334312438965)

            VStack {
                Text(weekdayText)
                    .font(.system(size: 12)) // Ajusta el tamaño de la fuente según sea necesario
                    .bold()
                Text(dayText)
                    .bold()
            }
            .foregroundColor(Color(red: 0.4196, green: 0.4314, blue: 0.6706))
            .padding()
        }
        .frame(width: 69, height: 117.5)
        .onTapGesture { // Agregado para actualizar la fecha seleccionada cuando se toca un DayView
            selectedDate = day.date
        }
    }

    var isSelected: Bool {
        Calendar.current.isDate(day.date, equalTo: selectedDate, toGranularity: .day)
    }

    var dayText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: day.date)
    }

    var weekdayText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: day.date).uppercased()
    }
}

struct MonthView: View {
    let days: [Day]
    @Binding var selectedDate: Date  // Binding para manejar la fecha seleccionada

    var body: some View {
        // El código existente de MonthView aquí
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: (UIScreen.main.bounds.width - (4 * 89)) / 5) {
                ForEach(days) { day in
                    DayView(day: day, selectedDate: $selectedDate) // Corregido aquí
                }
            }
            .padding(.horizontal, (UIScreen.main.bounds.width - (4 * 61.6)) / 10)
        }
    }
}


struct PictureView: View {
    @StateObject var pictureVM = PicturesViewModel()
    @State private var selectedUserId: Int = 2
    @State private var selectedDate: Date = Date()
    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    var body: some View {
        ZStack {
            Color(red: 0.1176, green: 0.1176, blue: 0.1176)
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Text("Mis fotos")
                    .font(.custom("Roboto Bold", size: 35))
                    .foregroundColor(Color.white)
                    .padding([.top, .leading])
                
                Text("Select Date")
                    .font(.custom("Kodchasan SemiBold", size: 23))
                    .foregroundColor(Color(#colorLiteral(red: 0.42, green: 0.43, blue: 0.67, alpha: 1)))
                    .padding([.leading])
                    .padding(.top, 0.01)
                    .lineSpacing(6.03)
                
                MonthView(days: generateDays(), selectedDate: $selectedDate)
                    .padding([.leading, .trailing])
                    .onChange(of: selectedDate) { newDate in  // Aquí está el .onChange
                        pictureVM.clearPictures()
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        let dateString = formatter.string(from: newDate)
                        pictureVM.fetchPictures(user: selectedUserId, date: dateString)
                    }

                ScrollView {
                                    LazyVGrid(columns: columns, spacing: 16) {
                                        ForEach(pictureVM.pictures) { picture in
                                            if let url = URL(string: picture.url) {
                                                AsyncImage(url: url) { image in
                                                    image.resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(minWidth: 0, maxWidth: .infinity)
                                                        .frame(height: 200)
                                                        .cornerRadius(10)  // Esquinas redondeadas
                                                        .clipped()  // Asegura que la imagen se recorte a las esquinas redondeadas
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                            }
                                        }
                                    }
                                    .padding()  // Espacio entre la cuadrícula y la orilla
                                }
                                .padding(.top, 16)
                
                Spacer()
            }
            .padding([.leading, .trailing])
        }
        .onAppear {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: selectedDate)
            pictureVM.fetchPictures(user: selectedUserId, date: dateString)
        }
    }

    func generateDays() -> [Day] {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month], from: Date())
        guard let firstDayOfMonth = calendar.date(from: dateComponents),
              let lastDayOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayOfMonth) else {
            return []
        }

        var currentDay = firstDayOfMonth
        var days = [Day]()
        while currentDay <= lastDayOfMonth {
            days.append(Day(date: currentDay))
            currentDay = calendar.date(byAdding: .day, value: 1, to: currentDay)!
        }
        return days
    }
}

struct PictureView_Previews: PreviewProvider {
    static var previews: some View {
        PictureView()
    }
}
