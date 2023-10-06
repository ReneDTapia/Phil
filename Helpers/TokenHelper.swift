//
//  TokenHelper.swift
//  Phil
//
//  Created by Rene  on 05/10/23.
//

import Foundation
import JWTDecode

class TokenHelper {
    static func isTokenExpired(token: String) -> Bool {
        do {
            let jwt = try decode(jwt: token)
            if let expirationDate = jwt.expiresAt, expirationDate < Date() {
                return true
            }
            return false
        } catch {
            return true
        }
    }
}
