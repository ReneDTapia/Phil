
//Este text Message view es para cuando ves tus chats con chat gpt

import SwiftUI

struct TextMessageView2: View {
    var message: Message
    
    var body: some View {
        HStack{
            if message.sentByUser {
                Spacer()
                Text(message.text)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.white)
                    .padding(.all,  10)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.purple)
                    )
                    .frame(maxWidth: 240, alignment: .trailing)
            } else {
                Text(message.text)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.white)
                    .padding(.all, 10)
                    .background(RoundedRectangle(cornerRadius: 16) .fill(.gray))
                    .frame(maxWidth: 240, alignment: .leading)
                Spacer()
            }
        }
    }
}

