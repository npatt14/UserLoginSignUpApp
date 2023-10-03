//
//  User.swift
//  UserLoginSignUpApp
//
//  Created by Nathan Patterson on 10/2/23.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let fullName: String
    let email: String
    
// computed property to get users initials
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
// PersonNameComponentsFormatter() will divide it up into components and return to us the first initial of the users first and last name
        if let components = formatter.personNameComponents(from: fullName) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        // if fails
        return "?"
    }
}

// extension for mock user data -> User.MOCK_USER.fullName
extension User {
    static var MOCK_USER = User(id: NSUUID().uuidString, fullName: "Jerry Geralson", email: "jg@gmail.com")
}
