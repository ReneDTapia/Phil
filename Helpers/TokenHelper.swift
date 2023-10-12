//
//  TokenHelper.swift
//  Phil
//
//  Created by Rene  on 05/10/23.
//

import Foundation
import JWTDecode
import KeychainSwift

class TokenHelper {
    
    private static let keychain = KeychainSwift()
       private static let tokenKey = "userToken"
       
       static func save(token: String) {
           keychain.set(token, forKey: tokenKey)
       }

       static func getToken() -> String? {
           return keychain.get(tokenKey)
       }

       static func deleteToken() {
           keychain.delete(tokenKey)
       }
    
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
