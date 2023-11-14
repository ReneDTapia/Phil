import Foundation
import JWTDecode
import KeychainSwift

class TokenHelper {
    
    private static let keychain = KeychainSwift()
    private static let tokenKey = "userToken"
    private static let userIDKey = "userID"
    
    static func save(token: String, userID: Int) {
        keychain.set(token, forKey: tokenKey)
        keychain.set(String(userID), forKey: userIDKey)
    }

    static func getToken() -> String? {
        return keychain.get(tokenKey)
    }

    static func getUserID() -> Int? {
        if let userIDString = keychain.get(userIDKey), let userID = Int(userIDString) {
            return userID
        }
        return nil
    }

    static func deleteToken() {
        keychain.delete(tokenKey)
        keychain.delete(userIDKey)
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
