import SwiftUI
import CoreML
import UIKit
import Vision

struct ModeloView: View {
    
    
    @State private var image: UIImage? = nil
    @State private var showImagePicker: Bool = false
    @State private var classificationLabel: String = ""
    @StateObject private var cameraViewModel = CameraViewController()
    
    var userId: Int
    
    let emotions = [
        "Angry": "😠",
        "Disgusted": "🤢",
        "Fearful": "😨",
        "Happy": "😊",
        "Neutral": "😐",
        "Sad": "😢",
        "Surprised": "😮"
    
    ]
    
    let emotionTranslations: [String: String] = [
        "Angry": "Enojado",
        "Disgusted": "Disgustado",
        "Fearful": "Asustado",
        "Happy": "Feliz",
        "Neutral": "Neutral",
        "Sad": "Triste",
        "Surprised": "Sorprendido"
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)

            VStack {
                Text((emotionTranslations[classificationLabel] ?? "") + " " + (emotions[classificationLabel] ?? ""))
                    .padding()
                    .foregroundColor(.white)

                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }

                Button("Tomate la foto") {
                    self.showImagePicker = true
                }
            }.onReceive(cameraViewModel.$detectedEmotion) { newEmotion in
                self.classificationLabel = newEmotion
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: self.$image, classificationLabel: self.$classificationLabel, userId: userId, cameraViewModel: cameraViewModel)
            }
        }
        .alert(isPresented: $cameraViewModel.showEmotionAlert) {
            Alert(
                title: Text("Emoción Detectada"),
                message: Text("¿Es correcta esta emoción?: \(cameraViewModel.detectedEmotion) \(emotions[cameraViewModel.detectedEmotion] ?? "")"),
                primaryButton: .default(Text("Sí")){
                    print("tu mama es mi papa")
                    // Enviar la emoción si es correcta
                        print("uploadedPhotoID: \(cameraViewModel.uploadedPhotoID)")
                        print("detectedEmotion: \(cameraViewModel.detectedEmotion)")
                        print("emotionIDs: \(cameraViewModel.emotionIDs)")
                        if let pictureID = cameraViewModel.uploadedPhotoID,
                           let emotionID = cameraViewModel.emotionIDs[cameraViewModel.detectedEmotion] {
                            print("Enviando emoción", pictureID, emotionID)
                            cameraViewModel.sendEmotion(pictureID: pictureID, emotionID: emotionID)
                        }
//                    }
                },
                secondaryButton: .cancel(Text("No, elegir otra")) {
                    cameraViewModel.shouldShowEmotionSelection = true
                }
            )
        }
        .sheet(isPresented: $cameraViewModel.shouldShowEmotionSelection) {
            EmotionSelectionView(cameraViewModel: cameraViewModel)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    @Binding var classificationLabel: String
    var userId: Int
    var cameraViewModel: CameraViewController

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self, cameraViewModel: cameraViewModel, userId: userId)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        var cameraViewModel: CameraViewController
        var userId: Int
        
        init(_ parent: ImagePicker, cameraViewModel: CameraViewController, userId: Int) {
                self.parent = parent
                self.cameraViewModel = cameraViewModel
                self.userId = userId
        }


        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
                classifyImage(image: uiImage)
            }
            
            parent.presentationMode.wrappedValue.dismiss()
            
        }

        func classifyImage(image: UIImage) {
            guard let buffer = image.toCVPixelBuffer() else {
                print("Failed to convert UIImage to CVPixelBuffer")
                return
            };do {
                
                let model = try EmotionClassifier(configuration: MLModelConfiguration())
                let prediction = try model.prediction(conv2d_input: buffer)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    print("Actualizando UI con la clasificación y mostrando alerta")
                    self.parent.classificationLabel = prediction.classLabel
                    self.cameraViewModel.detectedEmotion = prediction.classLabel
                    self.cameraViewModel.showEmotionAlert = true
                }

                // Aquí puedes llamar a la función addPicture del ViewModel
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let currentDateStr = dateFormatter.string(from: Date())
                
                let imageData = image.jpegData(compressionQuality: 0.5)
                let base64Image = imageData?.base64EncodedString()
               
                cameraViewModel.addPicture(url: base64Image ?? "", user: userId, date: currentDateStr)
                
            } catch {
                print("Error while making a prediction: \(error)")
            }
        }
    }
}
// Aquí agregarías tu lógica de clasificación
  
extension UIImage {
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let width = 48
        let height = 48
        let size = CGSize(width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
             kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         width,
                                         height,
                                         kCVPixelFormatType_OneComponent8,
                                         attrs,
                                         &pixelBuffer)
        
        if status != kCVReturnSuccess {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let grayscaleColorSpace = CGColorSpaceCreateDeviceGray()
        guard let context = CGContext(data: pixelData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
                                      space: grayscaleColorSpace,
                                      bitmapInfo: CGImageAlphaInfo.none.rawValue) else {
            return nil
        }
        
        UIGraphicsPushContext(context)
        guard let cgImage = resizedImage.cgImage else { return nil }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}

struct ModeloView_Previews: PreviewProvider {
    static var previews: some View {
        ModeloView(userId: TokenHelper.getUserID() ?? 0)
    }
}


