//
//  AuthViewModel.swift
//  UserLoginSignUpApp
//
//  Created by Nathan Patterson on 10/2/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

//MARK: WHAT THE AUTH VIEWMODEL WILL BE RESPONSIBLE FOR
// 1.) Make network calls and send notification to our UI when we need to update
// 2.) Will handle all of the errors. Example: When a user tries to log in with an invalid email

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

// our view will be able to observe this class and update the UI accordingly
@MainActor // @MainActor makes sure we are publishing changes on the main thread
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    // ^ will tell us whether or not we have a user logged in
    @Published var currentUser: User?
    
    init() {
        self.userSession = Auth.auth().currentUser
        // ^ when our AuthViewModel initializes it will check and see if there is a current user
        
        Task {
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("DEBUG: Failed to login with error \(error.localizedDescription)")
        }
    }
    
    // async function that can potentially throw an error (thats what will happen in the catch block)
    func createUser(withEmail email: String, password: String, fullName: String) async throws {
        do {
        // 1.) try to create a user using the firebase code
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            // 2.) once we get it back -> we set our user session property
            self.userSession = result.user
            // 3.) create our user object
            let user = User(id: result.user.uid, fullName: fullName, email: email)
            // 4.) encode that user object through the codable protocol
            let encodedUser = try Firestore.Encoder().encode(user)
            // 5.) upload that data to firestore
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            // 6.) 
            await fetchUser()
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
        }

    }
    
    // Client Side: Return us to sign in page
    // Backend: Sign the user out on firestore as well
    func signOut() {
        do {
            // sign out user on backend
            try Auth.auth().signOut()
            // wipes out user session and takes us back to lgin screen
            self.userSession = nil
            // wipe out current user data model
            self.currentUser = nil
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }

    }
    
    func deleteAccount() {
        print ("Example")

    }
    
    // func to fetch the user data
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
        
        print("DEBUG: Current user is \(self.currentUser) ")
    }
}
