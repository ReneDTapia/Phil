//
//  MoreOptions.swift
//  Phil
//
//  Created by alumno on 10/04/24.
//

import Foundation
import SwiftUI



struct MoreOptions: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack{
            VStack{
                HStack{
                    Button(action: {
                        withAnimation {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {HStack{
                        Image(systemName: "chevron.left")
                            .foregroundColor(.indigo)
                        
                        Text("Regresar")
                            .font(.caption)
                            .foregroundColor(.indigo)
                    }
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                }
                
                HStack{
                    Text("Más información")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                }
                .padding()
                
                VStack{
                    Text("Phil es una aplicación diseñada para apoyar el bienestar mental y emocional de sus usuarios.")
                    Spacer()
                    Text("La aplicación ofrece una amplia gama de recursos educativos sobre salud mental, incluyendo artículos y videos. Los temas abordados incluyen manejo del estrés, ansiedad, depresión, autoestima, relaciones saludables, técnicas de relajación y más. Todo el contenido está respaldado por profesionales de la salud mental.")
                    Spacer()
                    Text("Cuenta con un chatbot inteligente que está disponible las 24 horas del día, los 7 días de la semana. Los usuarios pueden interactuar con el chatbot para recibir apoyo emocional, consejos personalizados y técnicas de afrontamiento para manejar situaciones difíciles.")
                    Spacer()
                    HStack{
                        Text("Otras opciones")
                            .font(.title2)
                            .bold()
                        Spacer()
                    }
                    HStack{
                        Button(action: {
                            print("Hola")
                        }) {
                            
                            
                            HStack{
                                Text("Eliminar cuenta")
                                    .font(.title3)
                                    .foregroundColor(.red)
                                    .padding(.top)
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
                
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct MoreOptions_Previews: PreviewProvider {
    static var previews: some View {
        MoreOptions()
    }
}
