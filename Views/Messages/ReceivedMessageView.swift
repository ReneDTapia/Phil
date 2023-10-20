import SwiftUI

struct ReceivedMessageView: View {
    let message: Message
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(alignment: .bottom) {
            Text(message.text)
                .padding(10)
                .background(colorScheme == .dark ? Color(hex: "#E9E9EB") : Color(UIColor.systemGray5)) //
                .foregroundColor(.black)
                .cornerRadius(8)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 0.6 * UIScreen.main.bounds.width)
            Spacer()
        }
        .padding(.leading, 16)
    }
}


struct ReceivedMessageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ReceivedMessageView(message: Message(id: 2, userId: 1, text: "Mensajwe largo para probar el envoltorio de texto en la vista de mensajes recibidos.", sentByUser: false, conversationId: 1, sendAt: "2023-10-18"))
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Modo Oscuro")

            ReceivedMessageView(message: Message(id: 2, userId: 1, text: "Mensajefewfew largo para probar el envoltorio de texto fen la vista de mensajes recibidos.", sentByUser: false, conversationId: 1, sendAt: "2023-10-18"))
                .preferredColorScheme(.light)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Modo Claro")
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
