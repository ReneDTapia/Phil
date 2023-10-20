//
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
    
    var body: some View {
        ZStack{
            Color(hex:"F6F6FE")
                .ignoresSafeArea()
            VStack{
                
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
                            .padding(.bottom, -1)

                        QuestionBox(viewModel: viewModel)
                            .padding(-4)
                        
                        Spacer(minLength: 50)
                        
                        Text("Later").font(.custom("Montserrat Bold", size: 15)).underline()
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
                
                ProgressBarView(viewModel: viewModel, progress: self.scrollOffset / self.contentHeight*10.6)
                    .frame(height: 10)
                    .padding()
                
                Button(action: {
                    print("Botón presionado")
                    viewModel.postAnswers()
                }) {
                    Text("Done 👋")
                        .font(.custom("Montserrat-Bold", size: 15))
                        .foregroundColor(Color(hex:"000000"))
                        .padding()
                        .background(Color(hex: "F9F9F9"))
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
    var body: some View {
        VStack{
            ForEach(viewModel.formGroups.indices, id: \.self) { index in
                let forms = viewModel.formGroups[index]
                QuestionBoxRow(forms: forms, selectedButtons: $viewModel.selectedButtons[index], boxColors: boxColors, viewModel: viewModel)
            }
        }.onAppear(perform: viewModel.getForm)
    }
}

struct QuestionBoxRow: View {
    var forms: [InitialFormModel]
    @Binding var selectedButtons: [Int]
    let boxColors: [Color]
    @ObservedObject var viewModel: InitialFormViewModel
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "FFFFFF"))
                .frame(width: 345, height: 155)
                .shadow(color: Color(hex:"000000").opacity(0.1), radius:4, x:0, y:0)
                .padding(8)
            VStack(alignment: .leading){
                ForEach(0..<forms.count, id: \.self) { index in
                    ButtonRow(form: forms[index], selectedButtons: $selectedButtons, boxColor: boxColors[index % boxColors.count], viewModel: viewModel)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(30)
        }
    }
}


struct ButtonRow: View {
    var form: InitialFormModel
    @Binding var selectedButtons: [Int]
    let boxColor: Color
    @ObservedObject var viewModel: InitialFormViewModel
    
    var body: some View {
        HStack{
            Button(action :{
                if selectedButtons.contains(form.id) {
                    selectedButtons.removeAll(where: { $0 == form.id })
                    viewModel.selectedCount -= 1
                } else {
                    selectedButtons.append(form.id)
                    viewModel.selectedCount += 1
                }
            })
            {
                RoundedRectangle(cornerRadius: 2)
                    .strokeBorder(boxColor, lineWidth: 2)
                    .background(selectedButtons.contains(form.id) ? boxColor : Color.white)
                    .frame(width: 20, height: 20)
            }
            Text(form.texto)
                .font(.custom("Inter Regular", size: 15)).tracking(-0.41).multilineTextAlignment(.leading)
        }
    }
}



struct ProgressBarView : View {
    @ObservedObject var viewModel : InitialFormViewModel
    var progress: CGFloat

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





#Preview {
    InitialFormView()
}

//struct ViewOffsetKey: PreferenceKey {
//    typealias Value = CGFloat
//    static var defaultValue = CGFloat.zero
//    static func reduce(value: inout Value, nextValue: () -> Value) {
//        value += nextValue()
//    }
// Preguntar si puedo mejor sacar la progress bar de la scroll view para que siempre se vea. Ej: Arriba de Done
//}
