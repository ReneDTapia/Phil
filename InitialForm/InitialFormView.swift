//  InitialFormView.swift
//  Phil
//
//  Created by Leonardo García Ledezma  on 16/10/23.
//

import SwiftUI

struct InitialFormView: View {
    
    @State private var scrollOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    @ObservedObject var viewModel = InitialFormViewModel()
    @Environment(\.presentationMode) var presentationMode
    let userId: Int
    
    var body: some View {
        ZStack{
            Color(hex:"F6F6FE")
                .ignoresSafeArea()
            VStack{
                HStack{
                    Button(action: {
                        withAnimation {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title)
                            .foregroundColor(.black)
                    }
                    .padding(EdgeInsets(top: 50, leading: 15, bottom: 0, trailing: 0))
                    
                    Spacer()
                }
                
                ScrollView {
                    VStack {
                        Text("Phil")
                            .foregroundColor(Color(hex:"3A3B42"))
                            .font(Font.custom("Montserrat-ExtraBold", size: 30))
                        Image("logo_placeholder")
                            .resizable()
                            .frame(width: 55, height: 46)
                        Text("Hablanos de ti")
                            .font(Font.custom("Montserrat-Regular", size: 30)).multilineTextAlignment(.center)
                            .foregroundColor(.black)
                            .padding(.bottom, -1)
                        Text("¿Del 0 al 10 cómo te identificas?")
                            .font(Font.custom("Monsterrat-Regular", size: 14))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 10)
                            .foregroundColor(.black)
                        
                        QuestionBox(viewModel: viewModel)
                            .padding(-4)
                        
                        //                        Spacer(minLength: 50)
                        
                    }
                    .background(GeometryReader {
                        Color.clear.preference(key: ViewOffsetKey.self,
                                               value: -$0.frame(in: .named("scroll")).origin.y)
                    })
                    .background(GeometryReader {
                        Color.clear.preference(key: ViewHeightKey.self,
                                               value: $0.size.height)
                    })
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ViewOffsetKey.self) { self.scrollOffset = $0 }
                .onPreferenceChange(ViewHeightKey.self) { self.contentHeight = $0 }
                .padding()
                
                Spacer()
                
                ProgressBarView(viewModel: viewModel, progress: self.scrollOffset / self.contentHeight*1.26)
                    .frame(height: 10)
                    .padding()
                
                Button(action: {
                    print("Botón presionado")
                    Task {
                        do {
                            if viewModel.isFirstTime {
                                try await viewModel.postAnswers(user_id: userId)
                                viewModel.isFirstTime = false
                            } else {
                                try await viewModel.updateAnswers(user_id: userId)
                            }
                        } catch {
                            print("Error al enviar las respuestas: \(error)")
                        }
                    }
                }) {
                    Text("Done 👋")
                        .font(.custom("Montserrat-Bold", size: 15))
                        .foregroundColor(.black)
                        .padding()
                    //                        .background(Color(hex: "F9F9F9"))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(hex:"6B6EAB"), lineWidth: 0.8)
                                .frame(width: 345)
                        )
                }
                .padding()
                
                
            }
        }
    }
}



struct ViewOffsetKey: PreferenceKey {
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = max(value, nextValue())
    }
}

struct QuestionBox: View {
    @ObservedObject var viewModel = InitialFormViewModel()
    let boxColors: [Color] = [
        Color(hex: "ABFCC7"),
        Color(hex: "ABBFFC"),
        Color(hex: "F2A7A5"),
        Color(hex: "FFCE85")
    ]
    /**
     Le puse rickroll a el video 4 en adelante, quitar xd
     */
    var body: some View {
        VStack{
            ForEach(viewModel.formGroups.indices, id: \.self) { index in
                ForEach(viewModel.formGroups[index], id: \.self) { form in
                    ZStack{
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(hex: "FFFFFF"))
                            .frame(width: 345, height: 200)
                            .shadow(color: Color(hex:"000000").opacity(0.1), radius:4, x:0, y:0)
                        VStack(alignment: .center){
                            SliderRow(form: form, boxColor: boxColors[form.id % boxColors.count], viewModel: viewModel)
                        }
                        
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(30)
                        .padding(.bottom, -8)
                    }
                }
            }
        }.onAppear(perform: viewModel.getForm)
    }
}

struct SliderRow: View {
    var form: InitialFormModel
    let boxColor: Color
    @ObservedObject var viewModel: InitialFormViewModel
    @State private var sliderValue = 5.0
    @State private var playvideo = false
    
    var body: some View {
        VStack(alignment:.center){
            
            if playvideo == true{
                
                Video(url: form.videoURL, autoplay: 1)
                    .frame(width: 100, height: 60)
                    .padding(.bottom,10)
            }
            else{
                Image(systemName: "video")
                    .padding(.bottom, 10)
                    .foregroundColor(.black)
                    .onTapGesture {
                        playvideo.toggle()
                    }
            }
//            Video(url: form.videoURL, autoplay: 1)
//                .frame(width: 150, height: 50)
            
            Text(form.texto)
                .font(.custom("Monsterrat-Regular", size: 15)).tracking(-0.41).multilineTextAlignment(.center)
                .foregroundColor(.black)
            HStack {
                Image(systemName: "minus")
                    .foregroundColor(.black)
                Text("0")
                    .font(.custom("Monsterrat-Regular", size: 16))
                    .foregroundColor(.black)
                Slider(value:$sliderValue, in:0...10, step:1)
                    .accentColor(boxColor)
                    .onChange(of: sliderValue) { newValue in
                        viewModel.updateAnswer(for: form.id, with: newValue)
                    }
                Image(systemName: "plus")
                    .foregroundColor(.black)
                Text("10")
                    .font(.custom("Monsterrat-Regular", size: 16))
                    .foregroundColor(.black)
            }
        }
    }
}





struct ProgressBarView : View {
    @ObservedObject var viewModel : InitialFormViewModel
    var progress: CGFloat
    @State private var showingVideo = false
    
    var body : some View {
        GeometryReader { geometry in
            ZStack(alignment:.leading) {
                Rectangle().frame(width:
                                    geometry.size.width , height:
                                    geometry.size.height).opacity(0.3).foregroundColor(Color(UIColor.systemTeal))
                withAnimation(.easeInOut(duration: 0.2)) {
                    Rectangle().frame(width:
                                        min(CGFloat(self.progress)/CGFloat(self.viewModel.formGroups.count)*geometry.size.width,
                                            geometry.size.width) , height:
                                        geometry.size.height).foregroundColor(Color(UIColor.systemBlue))
                }
            }.cornerRadius(45.0)
        }
    }
}


//#Preview{
    //InitialFormView(userId: 1)
//}

struct InitialFormView_Previews: PreviewProvider {
    static var previews: some View {
        InitialFormView(userId: 1)
    }
}
