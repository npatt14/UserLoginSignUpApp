//
//  UserLoginSignUpAppApp.swift
//  UserLoginSignUpApp
//
//  Created by Nathan Patterson on 9/30/23.
//

import SwiftUI
import Firebase

@main
struct UserLoginSignUpAppApp: App {
    @StateObject var viewModel = AuthViewModel()
    
    init() {
        // ran when the app launches
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}


// the reason that we initialize AuthViewModel within the app folder is so that it is only initialized in one place and we can use @EnvironmentObject throughout the rest of the app to grab the same instance. 
