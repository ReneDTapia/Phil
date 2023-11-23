import SwiftUI
import CoreML
import Vision

import UIKit

struct ModeloView: View {
    @State private var image: UIImage? = nil
    @State private var showImagePicker: Bool = false
    @State private var classificationLabel: String = ""
    @StateObject private var cameraViewModel = CameraViewController()

    var body: some View {
        ZStack{
            Color.black
                .ignoresSafeArea(.all)
            VStack {
                Text(classificationLabel)
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
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: self.$image, classificationLabel: self.$classificationLabel, cameraViewModel: cameraViewModel)
            }
        }
        
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    @Binding var classificationLabel: String
    var cameraViewModel: CameraViewController

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self, cameraViewModel: cameraViewModel)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        var cameraViewModel: CameraViewController

        init(_ parent: ImagePicker, cameraViewModel: CameraViewController) {
            self.parent = parent
            self.cameraViewModel = cameraViewModel
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
                classifyImage(image: uiImage)
                cameraViewModel.uploadImage(image: uiImage)
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
                DispatchQueue.main.async {
                    self.parent.classificationLabel = prediction.classLabel
                }

                // Aquí puedes llamar a la función addPicture del ViewModel
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let currentDateStr = dateFormatter.string(from: Date())
                

                cameraViewModel.addPicture(url: cameraViewModel.url, user: 1, date: currentDateStr)
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
        ModeloView()
    }
}


