//
//  CameraViewController.swift
//  ModeloViewPruebas
//
//  Created by Jesús Daniel Martínez García on 10/11/23.
//

import AVFoundation
import UIKit
import Alamofire

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ObservableObject {
    
    @Published var url : String = ""
    
    @Published var detectedEmotion: String = ""
    @Published var showEmotionAlert: Bool = false
    @Published var shouldShowEmotionSelection: Bool = false
    

    @Published var uploadedPhotoID: Int?
    
    let emotionIDs = ["Angry": 1, "Disgusted": 2, "Fearful": 3, "Happy": 4, "Neutral": 5, "Sad": 6, "Surprised": 7]
    let emotionsSpanish = ["Enojado": 1, "Disgustado": 2, "Asustado": 3, "Feliz": 4, "Neutral": 5, "Triste": 6, "Sorprendido": 7]
    override func viewDidLoad() {
        super.viewDidLoad()
        checkCameraAccess()
    }
    
    func checkCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if !granted {
                  
                }
            }
        default:
            break
        }
    }
    
    @IBAction func takePhotoButtonTapped(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    @Published var networkError: String?
    
    // Función para añadir la imagen. Nota que ahora 'date' es de tipo 'String'.
    func addPicture(url: String, user: Int, date: String) {
        
        //simon pa lo que digas (lol)
        let requestURL = "https://philbackend.onrender.com/api/auth/AddPicture"
        let parameters: [String: Any] = [
            "url": url,
            "user": user,
            "date": date
        ]
        
        AF.request(requestURL, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: PictureResponse.self) { [weak self] response in
                switch response.result {
                case .success(let pictureResponse):
                    // Almacenar el ID de la imagen  en la variabl epublished
                    self?.uploadedPhotoID = pictureResponse.id
                    
//                    print(pictureResponse.message) // Solo para depuraciónxd
                case .failure(let error):
                    print("Error al añadir la imagen: \(error.localizedDescription)")
                    self?.networkError = error.localizedDescription
                }
            }
    }

    
    func sendEmotion(pictureID: Int, emotionID: Int) {
      
        print("Enviando emoción. Emotion ID: \(emotionID), Picture ID: \(pictureID)")

        let requestURL = "https://philbackend.onrender.com/api/auth/AddPicturesEmotion" // Ajusta a tu URL
        let parameters: [String: Any] = [
            "emotion_id": emotionID,
            "pictures_id": pictureID 
        ]
        
        AF.request(requestURL, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    print("Emoción enviada con éxito.")
                case .failure(let error):
                    print("Error al enviar la emoción: \(error.localizedDescription)")
                   
                    if let data = response.data, let responseStr = String(data: data, encoding: .utf8) {
                        print("Respuesta del servidor: \(responseStr)")
                    }
                }
            }
    }




    
}
    

