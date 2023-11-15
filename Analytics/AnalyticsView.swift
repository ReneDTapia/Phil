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
        
        ZStack(alignment: .leading) {
            Color.black
                .ignoresSafeArea(.all)
            VStack(alignment: .leading) {
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
        
        
        
        
    }
}

struct BarChart: View {
    @ObservedObject var viewModel = AnalyticsViewModel()
    let minimenu: [String] = ["10", "30", "all"]
    @State private var selectedIndex: Int? = nil
    
    var values: [CGFloat] {
        return viewModel.emotions.map { CGFloat($0.Percentage) }
    }
    //    var values: [CGFloat] = [80, 10, 10, 50, 70]
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 17)
                    .fill(Color.white)
                    .frame(width: geometry.size.width, height: geometry.size.height/2.2)
                    .shadow(color: Color(hex: "B9B6B6"), radius:2, x:0, y:0)
                ZStack{
                    VStack {
                        Text("Your feelings last days")
                            .font(.custom("Inter Semi Bold", size: 20))
                            .tracking(-0.41)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
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
                                            .frame(width: geometry.size.width/20, height: geometry.size.width/20)
                                            .padding(.horizontal)
                                        Text(minimenu[i]).font(.custom("Inter Semi Bold", size: 10)).foregroundColor(Color.white).tracking(-0.41).multilineTextAlignment(.center)
                                        
                                    }
                                }
                            }
                        }
                        HStack{
                            VStack(alignment: .trailing){
                                ForEach(0..<6) { index in
                                    Text("\(100 - index * 20)%")
                                        .font(.custom("Inter Semi Bold", size: 15))
                                        .foregroundColor(Color.black)
                                        .padding(.bottom,-0.5)
                                        .padding(.leading, 4)
                                }
                            }
                            VStack(spacing: 22){
                                ForEach(0..<6) { index in
                                    Divider()
                                        .background(Color.gray)
                                        .opacity(0.5)
                                }
                            }.padding(.trailing, 44)
                        }
                    }.frame(width: geometry.size.width, height: geometry.size.height/2.2, alignment: .top)
                    
                    
                    HStack(spacing: geometry.size.width/10.8) {
                        
                        ForEach(0..<values.prefix(5).count, id:\.self) { index in
                            VStack {
                                Spacer()
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(hex: "6B6EAB"))
                                    .frame(width: geometry.size.width/20, height: values[index]*1.29)
                                    .clipShape(Rectangle().offset(y: -10))
                            }
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height/4)
                    
                    HStack(spacing: geometry.size.width/20){
                        
                        ForEach(0..<5)
                        {
                            i in
                            VStack{
                                Spacer()
                                ZStack {
                                    
                                    RoundedRectangle(cornerRadius: 80)
                                        .fill(Color(hex: "ECBB5F"))
                                    
                                    RoundedRectangle(cornerRadius: 80)
                                        .strokeBorder(Color(hex: "6B6EAB"), lineWidth: 4)
                                }
                                .frame(width: geometry.size.width/11, height: geometry.size.width/11)
                                
                            }
                            
                        }
                    }.frame(width: geometry.size.width, height: geometry.size.height/2.5)
                    
                }
            }
        }.onAppear {
            viewModel.getAnal(userId: 1)
            print("Emotions fetched")
        }
    }
}


//#Preview{
    //TabBarView(user: 1)
//}



