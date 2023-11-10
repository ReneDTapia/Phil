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
                        .padding(EdgeInsets(top: 20, leading: 20, bottom: 8, trailing: 10))
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
    // Arreglo de alturas para cada barra de la gráfica
    let values: [CGFloat] = [51, 20, 30, 20, 80]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 17)
                    .fill(Color.white)
                    .frame(width: geometry.size.width, height: geometry.size.height/2.5)
                    .shadow(color: Color(hex: "B9B6B6"), radius:2, x:0, y:0)
                
                ZStack{
                    HStack{
                        VStack(alignment: .trailing){
                            ForEach(0..<6) { index in
                                Text("\(100 - index * 20)%")
                                    .font(.custom("Inter Semi Bold", size: 15))
                                    .foregroundColor(Color.black)
                            }.padding(.bottom, 1)
                        }
                        VStack(spacing: 22){
                            ForEach(0..<6) { index in
                                Divider()
                                    .background(Color.gray)
                                    .opacity(0.5)
                            }.padding(.bottom, 1)
                        }
                    }
                    .frame(width: geometry.size.width/1.1, height: geometry.size.height/2.5)
                    VStack {
                        Text("Your feelings last days")
                            .font(.custom("Inter Semi Bold", size: 24))
                            .tracking(-0.41)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 188)
                    }
                    
                    HStack(spacing: 22) {
                        Spacer()
                        
                        ForEach(0..<values.count, id:\.self) { index in
                            VStack {
                                Spacer()
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(hex: "6B6EAB"))
                                    .frame(width: 20, height: values[index])
                                    .clipShape(Rectangle().offset(y: -10))
                                    
                            }
                            .padding(.leading, 15)
                            .padding(.trailing, 3)
                        }
                    }.padding(.bottom, 218)
                        .padding(.trailing, 25)
                }
            }
        }
    }
}







/*
 struct BarChart: View {
 var body: some View {
 GeometryReader { geometry in
 ZStack {
 RoundedRectangle(cornerRadius: 17)
 .fill(Color(hex: "FFFFFF"))
 .frame(width: geometry.size.width, height: geometry.size.height/2.5)
 .shadow(color: Color(hex: "B9B6B6"), radius:2, x:0, y:0)
 
 ZStack{
 
 // Líneas de fondo
 VStack{
 ForEach(0..<6) { index in
 HStack{
 VStack{
 Text("\(100 - index * 20)%") // Agrega los porcentajes
 .font(.custom("Inter Semi Bold", size: 10))
 .foregroundColor(Color(hex:"000000"))
 
 }.padding(.trailing, 8)
 VStack{
 Divider()
 .background(Color.gray)
 .opacity(0.5)
 }
 }
 }
 }
 .frame(width: geometry.size.width/1.1, height: geometry.size.height/2.5) // Ajusta el ancho de las líneas de fondo
 .padding(.horizontal)
 
 VStack {
 Text("Your feelings last days")
 .font(.custom("Inter Semi Bold", size: 24))
 .tracking(-0.41)
 .multilineTextAlignment(.center)
 .padding(.bottom, 180)
 }
 
 HStack {
 ForEach(0..<5) { _ in
 Rectangle()
 .fill(Color(hex: "6B6EAB"))
 .frame(width: 20, height: 51)
 .cornerRadius(10)
 .padding(10)
 }
 }
 }
 }
 }
 }
 }
 */




#Preview{
    ContentView()
}
