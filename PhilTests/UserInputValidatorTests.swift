//
//  UserInputValidatorTests.swift
//  PhilTests
//
//  Created by Rene  on 09/10/23.
//

import Foundation
import XCTest
@testable import Phil
 
class UserInputValidatorTests: XCTestCase {

    func testValidEmail() {
        XCTAssertTrue(UserInputValidator.isValidEmail("test@example.com"))
    }

    func testInvalidEmail() {
        XCTAssertFalse(UserInputValidator.isValidEmail("invalidEmail"))
    }

    func testPasswordUppercaseRequirement() {
        XCTAssertEqual(UserInputValidator.passwordValidationError("password1@"), "Password must have at least one uppercase character.")
    }

    func testPasswordLowercaseRequirement() {
        XCTAssertEqual(UserInputValidator.passwordValidationError("PASSWORD1@"), "Password must have at least one lowercase character.")
    }

    func testPasswordNumberRequirement() {
        XCTAssertEqual(UserInputValidator.passwordValidationError("Password@"), "Password must have at least one number.")
    }

    func testPasswordSpecialCharacterRequirement() {
        XCTAssertEqual(UserInputValidator.passwordValidationError("Password1"), "Password must have at least one special character.")
    }

    func testValidPassword() {
        XCTAssertNil(UserInputValidator.passwordValidationError("Password1@"))
    }
    
    func testValidPasswordWithDifferentSpecialCharacters() {
        XCTAssertNil(UserInputValidator.passwordValidationError("Password1@"))
        XCTAssertNil(UserInputValidator.passwordValidationError("Password1$"))
        XCTAssertNil(UserInputValidator.passwordValidationError("Password1%"))
        XCTAssertNil(UserInputValidator.passwordValidationError("Password1&"))
        // ... (y así sucesivamente para otros caracteres especiales permitidos)
    }

    func testValidPasswordWithMixedCombinations() {
        XCTAssertNil(UserInputValidator.passwordValidationError("P@ssw0rd1"))
        XCTAssertNil(UserInputValidator.passwordValidationError("Pass$w0rd"))
        XCTAssertNil(UserInputValidator.passwordValidationError("P1%ssword"))
        // ... (y así sucesivamente para otras combinaciones)
    }


    // Puedes continuar agregando más pruebas según lo necesites...
}
