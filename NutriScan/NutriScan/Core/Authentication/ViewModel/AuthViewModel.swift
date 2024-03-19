//
//  AuthViewModel.swift
//  NutriScan
//
//  Created by Shadan Farahbakhsh on 2024-03-18.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    //if the user is sign in store data locally in the device
    init(){
        self.userSession = Auth.auth().currentUser
        Task{
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        print("Sign in ...")
    }
    
    func createUser(withEmail email: String, password: String, fullname: String, weight: String,
                    height: String, targetWeight: String, gender : String) async throws {
        do{
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
         

            let user = User(id: result.user.uid, fullname: fullname, email: email, weight: weight, height: height, targetWeight: targetWeight, gender: gender)
            //Encode data
            let encodedUser = try Firestore.Encoder().encode(user)
            //upload data to firestore
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
        } catch {
            print("DEBUG: Failed to creat user with error \(error.localizedDescription)")
        }
    }
    
    
    func signOut() {
        
    }
    
    func deleteAccount() {
        
    }
    
    func fetchUser() async {
        //get current user id
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
       self.currentUser = try? snapshot.data(as: User.self)
        
//        print("Debug: Current user is \(self.currentUser)")
        
    }
//    func fetchUser() async {
//        do {
//            // Get current user ID
//            guard let uid = Auth.auth().currentUser?.uid else {
//                print("Error: User ID not available.")
//                return
//            }
//            
//            // Fetch user document from Firestore
//            let documentSnapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
//            
//            // Check if document exists
//            guard let data = documentSnapshot.data() else {
//                print("Error: User document not found.")
//                return
//            }
//            
//            // Decode user data into User object
//            if let user = try? documentSnapshot.data(as: User.self) {
//                self.currentUser = user
//            } else {
//                print("Error: Failed to decode user data.")
//            }
//        } catch {
//            // Handle any errors
//            print("Error fetching user: \(error.localizedDescription)")
//        }
//    }

    
}
