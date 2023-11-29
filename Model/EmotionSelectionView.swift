//
//  EmotionSelectionView.swift
//  Phil
//
//  Created by Jesús Daniel Martínez García on 28/11/23.
//

import SwiftUI

struct EmotionSelectionView: View {
    @StateObject var cameraViewModel: CameraViewController

    let emotions = [
        "Enojado": "😡",
        "Disgustado": "🤢",
        "Asustado": "😨",
        "Feliz": "😄",
        "Neutral": "😐",
        "Triste": "😢",
        "Sorprendido": "😲"
        
    ]
    var body: some View {
        List(emotions.keys.sorted(), id: \.self) { emotion in
            Button(action: {
                DispatchQueue.main.async {
                    cameraViewModel.detectedEmotion = emotion
                    cameraViewModel.shouldShowEmotionSelection = false

                    // Enviar la emoción y el ID de la foto si es que los agarra el view model siuu (view controller por que luis no le sabe)
                    if let pictureID = cameraViewModel.uploadedPhotoID,
                    let emotionID = cameraViewModel.emotionsSpanish[emotion] {
                        cameraViewModel.sendEmotion(pictureID: pictureID, emotionID: emotionID)
                    }
                }
            }) {
                HStack {
                    Text("\(emotions[emotion] ?? "") \(emotion)")
                        .font(.title)
                        .padding()
                    Spacer()
                }
            }
        }
        .listStyle(GroupedListStyle())
    }
}
