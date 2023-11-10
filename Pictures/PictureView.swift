import SwiftUI

struct Day: Identifiable {
    let id = UUID()
    let date: Date
}

struct DayView: View {
    var day: Day
    @Binding var selectedDate: Date
    @Environment(\.calendar) var calendar

    var body: some View {
        Button(action: {
            self.selectedDate = day.date
        }) {
            VStack {
                Text(weekdayText)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)

                ZStack {
                    Circle()
                        .fill(isSelected ? Color.blue : Color.white.opacity(0.8))
                        .frame(width: 30, height: 30)

                    Text(dayText)
                        .bold()
                        .foregroundColor(isSelected ? .white : .primary)
                }
            }
        }
        .frame(width: 44, height: 60)
    }

    var isSelected: Bool {
        calendar.isDate(day.date, inSameDayAs: selectedDate)
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

struct WeekView: View {
    @Binding var selectedDate: Date
    @Environment(\.calendar) var calendar

    var body: some View {
        VStack {
            Text(monthText)
                .font(.title)
                .padding(.bottom, 4)
                .foregroundColor(Color.purple)

            HStack {
                Button(action: {
                    self.adjustDate(by: -1)
                }) {
                    Image(systemName: "chevron.left.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color.purple)
                }

                LazyHStack(spacing: 0) {
                    ForEach(daysInWeek(for: selectedDate)) { day in
                        DayView(day: day, selectedDate: $selectedDate)
                    }
                }

                Button(action: {
                    self.adjustDate(by: 1)
                }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color.purple)
                }
            }
        }
    }

    func adjustDate(by weeks: Int) {
        if let newDate = calendar.date(byAdding: .weekOfYear, value: weeks, to: selectedDate) {
            selectedDate = newDate
        }
    }

    func daysInWeek(for date: Date) -> [Day] {
        var days: [Day] = []
        guard let weekRange = calendar.range(of: .weekday, in: .weekOfYear, for: date) else { return [] }
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        for offset in weekRange {
            if let weekdayDate = calendar.date(byAdding: .day, value: offset - 1, to: startOfWeek) {
                days.append(Day(date: weekdayDate))
            }
        }
        return days
    }

    var monthText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: selectedDate)
    }
}

struct PictureView: View {
    @ObservedObject var pictureVM = PicturesViewModel()
    @State private var selectedDate: Date = Date()

    // Suponiendo que cada imagen ocupe aproximadamente la mitad de la pantalla menos el padding y el espacio entre imágenes.
    private let imageWidth = (UIScreen.main.bounds.width / 2) - (16 + 8) // 16 de padding y 8 de spacing

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Text("Your Photos")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()

                WeekView(selectedDate: $selectedDate)

                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(pictureVM.pictures) { picture in
                            AsyncImage(url: URL(string: picture.url)) { phase in
                                switch phase {
                                case .success(let image):
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: imageWidth, height: 200)
                                        .cornerRadius(10)
                                case .failure(_):
                                    Image(systemName: "photo") // Puedes personalizar la imagen de error.
                                        .resizable()
                                        .frame(width: imageWidth, height: 200)
                                        .cornerRadius(10)
                                        .foregroundColor(.gray)
                                case .empty:
                                    Image(systemName: "photo") // Imagen de placeholder.
                                        .resizable()
                                        .frame(width: imageWidth, height: 200)
                                        .cornerRadius(10)
                                        .foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(height: 200) // Esto mantiene el tamaño de la imagen fijo
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            fetchPictures()
        }
        .onChange(of: selectedDate) { _ in
            pictureVM.pictures = []
            fetchPictures() }
    }

    func fetchPictures() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        pictureVM.fetchPictures(user: 2, date: dateString)
    }
}

struct PictureView_Previews: PreviewProvider {
    static var previews: some View {
        PictureView()
    }
}
