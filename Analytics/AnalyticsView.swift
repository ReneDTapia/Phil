//
//  AnalyticsView.swift
//  Phil
//
//  Created by Leonardo García Ledezma on 06/11/23.
//

import SwiftUI


struct AnalyticsView: View{
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
    @ObservedObject var viewModel = AnalyticsViewModel()
    let minimenu: [String] = ["10", "30", "all"]
    @State private var selectedIndex: Int? = nil
    
    var values: [CGFloat] {
        return viewModel.emotions.map { CGFloat($0.Percentage) }
    }
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 17)
                    .fill(Color.white)
                    .frame(width: geometry.size.width, height: geometry.size.height/2.15)
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
                    .frame(width: geometry.size.width/1.05, height: geometry.size.height/2.2)
                    VStack {
                        Text("Your feelings last days")
                            .font(.custom("Inter Semi Bold", size: 20))
                            .tracking(-0.41)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 190)
                    }
                    HStack{
                        ForEach(0..<minimenu.count, id:\.self){
                            i in
                            Button(action: {
                                self.selectedIndex = i
                            }) {
                                ZStack
                                {
                                    Circle()
                                        .fill(self.selectedIndex == i ? Color(hex: "6B6EAB") : Color(hex: "B9B6B6"))
                                        .frame(width: 16, height: 16)
                                        .padding(30)
                                    
                                    Text(minimenu[i]).font(.custom("Inter Semi Bold", size: 10)).foregroundColor(Color.white).tracking(-0.41).multilineTextAlignment(.center)
                                }
                            }
                        }
                    }.padding(.bottom, 150)
                        .padding(.leading, 38)
                    HStack(spacing: 22) {
                        Spacer()
                        ForEach(0..<values.prefix(5).count, id:\.self) { index in
                            VStack {
                                Spacer()
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(hex: "6B6EAB"))
                                    .frame(width: 20, height: values[index]*1.29)
                                    .clipShape(Rectangle().offset(y: -10))
                            }
                            .padding(.leading, 15)
                            .padding(.trailing, 3)
                        }
                    }.padding(.bottom, 164)
                        .padding(.trailing, 25)

                    HStack(spacing: 22){
                        ForEach(0..<5)
                        {
                            i in
                            ZStack {
                                RoundedRectangle(cornerRadius: 80)
                                    .fill(Color(hex: "ECBB5F"))
                                
                                RoundedRectangle(cornerRadius: 80)
                                    .strokeBorder(Color(hex: "6B6EAB"), lineWidth: 4)
                            }
                            .frame(width: 30, height: 30)
                        }
                        .padding(.top, 162)
                        .padding(.leading, 8)
                    }
                    .padding(.trailing, 1)
                    .padding(.leading, 38)
                }
            }
        }.onAppear {
            viewModel.getAnal() {
                print("Emotions fetched")
            }
        }
    }
}

#Preview{
    AnalyticsView()
}
