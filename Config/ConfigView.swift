//
//  ConfigView.swift
//  Phil
//
//  Created by alumno on 21/03/24.
//

import Foundation
import SwiftUI

struct Config: View {
    var body: some View {
        NavigationStack{
            VStack{
                HStack{
                    Text("Configuración")
                        .font(.title)
                        .bold()
                    Spacer()
                }
                .padding(25)
            }
            
        }
        
    }
}

struct Config_Previews: PreviewProvider {
    static var previews: some View {
        Config()
    }
}
