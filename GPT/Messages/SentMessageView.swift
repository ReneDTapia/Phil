import SwiftUI
//componente sin uso 
struct SentMessageView: View {
    let message: Message

    var body: some View {
        HStack {
            Spacer()
            Text(message.text)
                .padding(10)
                .background(Color(UIColor.systemPurple))
                .foregroundColor(.white)
                .cornerRadius(8)
                .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                .frame(maxWidth: 0.6 * UIScreen.main.bounds.width)
        }
        .padding(.trailing, 16)
    }
}

struct SentMessageView_Previews: PreviewProvider {
    static var previews: some View {
        SentMessageView(message: Message(id: 1, userId: 1, text: "Hola, ¿cómo estás te gustsa la pizza? Esto es un mensaje largo para probar cómo se ve en la pantalla y asegurarnos de eque no se extienda demasiado.", sentByUser: true, conversationId: 1, sendAt: "2023-10-18"))
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}

