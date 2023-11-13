//
//  CameraModel.swift
//  Camara
//
//  Created by alumno on 27/10/23.
//

import Foundation


struct Camera: Encodable, Decodable{
    let url: String
    let user: Int
    let Date: String
}

struct PictureResponse: Codable {
    var success: Bool
    var message: String
    var picture: Camera
}
