import SwiftUI
//componente sin uso
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


