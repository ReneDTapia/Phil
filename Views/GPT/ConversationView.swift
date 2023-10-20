//
//  ConversationView.swift
//  Phil
//
//  Created by Jesús Daniel Martínez García on 20/10/23.
//

import SwiftUI

struct ConversationView: View {
    
    @EnvironmentObject var viewModel : GPTViewModel
    
    var body: some View {
        ScrollView{
            ForEach(viewModel.messages) {message in TextMessageView(message: message)}
        }
    }
}

struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView().environmentObject(GPTViewModel())
    }
}
