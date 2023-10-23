//
//  GPTView.swift
//  Phil
//
//  Created by Jesús Daniel Martínez García on 19/10/23.
//

import SwiftUI


struct GPTView: View {
    var viewModel = GPTViewModel()
    @State var prompt : String = "Explicame 10 emociones comunes"
    
    @State private var showMenu = false
    
    var body: some View {
        //Side bar
        GeometryReader{
            
            geometry in
            
            ZStack(alignment: .leading) {
                Color.black
                    .ignoresSafeArea(.all)
                VStack(alignment: .leading) {
                    HStack {
                        // Botón del menú
                        Button(action: {
                            withAnimation {
                                self.showMenu.toggle()
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Circle()
                            .fill(Color.white)
                            .frame(width: 50, height: 50)
                    }
                    .padding(EdgeInsets(top: 30, leading: 20, bottom: 0, trailing: 20))
                    Text("Chatea con Phil")
                        .font(.largeTitle)
                        .bold()
                        .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 10))
                        .foregroundColor(.white)
                    
                    
                    ////
                    //seccionchatgpt(?)
                    
                    Spacer()
                    
                    VStack {
                        ConversationView()
                            .environmentObject(viewModel)
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity)
                        HStack{
                            TextField("Chatea con Phil", text: $prompt, axis: .vertical)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(25)
                                .lineLimit(6)
                            Button {
                                Task {
                                    await viewModel.send(message : prompt)
                                }
                            } label: {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(Color.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.purple)
                                    .cornerRadius(22)
                            }
                            .padding(.leading, 8)
                        }
                        
                    }.padding()
                            
                    
                    //AQUI TERMINA LA SECCION DE GPT
                
                }
                
                
                if showMenu{
                    ZStack{
                        Color(.black)
                    }
                    .opacity(0.5)
                    .onTapGesture {
                        withAnimation{
                            showMenu = false
                        }
                        
                    }
                }
                
                HStack{
                    Menu(showMenu: $showMenu)
                        .offset(x:showMenu ? 0 : UIScreen.main.bounds.width * -1)
                        .frame(width: 300)
                    
                }
                
            }
        }
    }
}

struct GPTView_Previews: PreviewProvider {
    static var previews: some View {
        GPTView()
    }
}

