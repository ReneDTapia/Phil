//
//  AnalyticsView.swift
//  Phil
//
//  Created by Leonardo García Ledezma on 06/11/23.
//

import SwiftUI


struct ContentView: View{
    @State private var showMenu = false
    
    var body: some View{
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
                    Text("Metas Diarias")
                        .font(.largeTitle)
                        .bold()
                        .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 10))
                        .foregroundColor(.white)
                    Spacer()
                    
                    // Aqui
                    BarChart()
                    
                }.padding()
                
                // touchid and faceid instead of logging in, la clave no se envía y le da seguridad
                
                
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
                    .offset(x:showMenu ? 0 : UIScreen.main.bounds.width * -1, y:0)
                    .frame(width: 300, height:.infinity)
                    .ignoresSafeArea(.all)
                
            }
            
        }
        
    }
}

struct BarChart: View {
    // atributo que lea el rect
    var body : some View{
        ZStack{
            //Rectangle 2
            RoundedRectangle(cornerRadius: 17)
                .fill(Color(hex: "FFFFFF"))
            .frame(width: 345, height: 232)
            .shadow(color: Color(hex: "B9B6B6"), radius:4, x:0, y:0)
            VStack{
                //Your feelings last days
                Text("Your feelings last days").font(.custom("Inter Semi Bold", size: 20)).tracking(-0.41).multilineTextAlignment(.center)
                    .bold()
                    .padding(.bottom, 180)
            }
            HStack{
                ForEach(0..<5) { _ in
                    Rectangle()
                        .fill(Color(hex: "6B6EAB"))
                        .frame(width: 20, height: 80) // Ajusta la altura según sea necesario
                        .cornerRadius(10)
                        
                }
            }
        }
        
    }
}


#Preview{
    ContentView()
}
