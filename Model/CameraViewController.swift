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
   
    override func viewDidLoad() {
        super.viewDidLoad()
        checkCameraAccess()
    }
    
    func checkCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // El usuario ya autorizó el acceso a la cámara
            break
        case .notDetermined: // No se ha solicitado el permiso aún
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if !granted {
                    // El usuario no otorgó el permiso
                }
            }
        default: // El permiso fue negado
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
        // Preparamos el endpoint y los parámetros
        let requestURL = "https://philbackend.onrender.com/api/auth/AddPicture" // Cambia esto a tu URL real
        let parameters: [String: Any] = [
            "url": url,
            "user": user,
            "date": date // Ya no necesitas formatear 'date' ya que ya es un String.
        ]

        // Realizamos la solicitud POST
        AF.request(requestURL, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseJSON { [weak self] response in
                switch response.result {
                case .success:
                    print("Imagen añadida con éxito.")
                case .failure(let error):
                    print("Error al añadir la imagen: \(error.localizedDescription)")
                    self?.networkError = error.localizedDescription
                }
            }
    }
    
    func uploadImage(image: UIImage) {
        let imageData = image.jpegData(compressionQuality: 0.5)
        let base64Image = imageData?.base64EncodedString()

        let parameters: [String: String] = [
            "key": "7837d429b99d3d1ca4dec5929f5b4a41",
            "image": base64Image ?? "",
            "name": ""
        ]

        AF.request("https://api.imgbb.com/1/upload", method: .post, parameters: parameters)
            .responseJSON { [self] response in
                switch response.result {
                case .success(let value):
                if let jsonResponse = value as? [String: Any],
                       let data = jsonResponse["data"] as? [String: Any],
                       let url = data["url"] as? String {
                        print("URL de la imagen: \(url)")
                    
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let currentDateStr = dateFormatter.string(from: Date())

                        
                        let currentUser = "2"
                                                
                                                
                    self.addPicture(url: url, user: 1, date: currentDateStr)
                    }
                case .failure(let error):
                    // Manejar el error
                    print(error.localizedDescription)
                }
            }
    }
}
    
    

