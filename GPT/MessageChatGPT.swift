import SwiftUI
import SwiftOpenAI

struct MessageChatGPT: Identifiable {
    let id = UUID()
    var text: String
    var role: ChatCompletionsRole
    var hidden: Bool = false
}
