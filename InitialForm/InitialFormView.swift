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
    @State private var showAlert = false
    @Environment(\.presentationMode) var presentationMode
    let userId: Int
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack {
                        Text("Cuestionario diario")
                            .font(.title)
                            .bold()
                        Text("¿Del 0 al 10 cómo te identificas?")
                            .font(.subheadline)
                        
                        QuestionBox(viewModel: viewModel)
                            .padding(-4)
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
                
                // Submit Button
                Button(action: {
                    Task {
                        do {
                            if viewModel.isFirstTime {
                                try await viewModel.postAnswers(user_id: userId)
                                viewModel.isFirstTime = false
                            } else {
                                try await viewModel.updateAnswers(user_id: userId)
                            }
                            showAlert = true
                        } catch {
                            print("Error al enviar las respuestas: \(error)")
                        }
                    }
                }) {
                    Text("Terminado 👋")
                        .padding()
                        .foregroundColor(.indigo)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.indigo, lineWidth: 0.8)
                                .frame(width: 345)
                        )
                }
                .alert(isPresented: $showAlert){
                    Alert(title: Text("Respuestas enviadas"), message: Text("Tus respuestas han sido enviadas correctamente"), dismissButton: .default(Text("Ok")))
                }
                .padding()
            }
            .navigationBarHidden(true)
            .background(Color.white)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .interactiveDismissDisabled(false)
    }
}

// PreferenceKeys para tracking de scroll
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
        VStack {
            ForEach(viewModel.formGroups.indices, id: \.self) { index in
                ForEach(viewModel.formGroups[index], id: \.self) { form in
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(hex: "FFFFFF"))
                            .frame(width: 365, height: 300)
                            .shadow(color: Color(hex:"000000").opacity(0.1), radius:4, x:0, y:0)
                        VStack(alignment: .center) {
                            SliderRow(form: form, boxColor: boxColors[form.id % boxColors.count], viewModel: viewModel)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(30)
                        .padding(.bottom, -8)
                    }
                }
            }
        }
        .onAppear(perform: viewModel.getForm)
    }
}

struct SliderRow: View {
    var form: InitialFormModel
    let boxColor: Color
    @ObservedObject var viewModel: InitialFormViewModel
    @State private var sliderValue = 5.0
    @State private var playvideo = true
    
    var body: some View {
        VStack(alignment:.center) {
            if playvideo {
                Video(url: form.videoURL, autoplay: 1)
                    .frame(width: 330, height: 200)
                    .padding(.bottom, 10)
                    .cornerRadius(18)
            } else {
                Image(systemName: "video")
                    .padding(.bottom, 10)
                    .foregroundColor(.black)
                    .onTapGesture {
                        playvideo.toggle()
                    }
            }
            
            Text(form.texto)
                .font(.custom("Monsterrat-Regular", size: 15))
                .tracking(-0.41)
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
            
            HStack {
                Image(systemName: "minus")
                    .foregroundColor(.black)
                Text("0")
                    .font(.custom("Monsterrat-Regular", size: 16))
                    .foregroundColor(.black)
                Slider(value: $sliderValue, in: 0...10, step: 1)
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

#Preview {
    MainView()
}
