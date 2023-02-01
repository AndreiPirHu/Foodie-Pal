//
//  UserSettingsEditView.swift
//  Foodie Pal
//
//  Created by Andrei Pirogov on 2023-02-01.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct UserSettingsEditView: View {
    @State var userSettings = [UserSettings]()
    @State var receivedSetting : String
    
    
    @State var editedSetting : String = ""
    
    let db = Firestore.firestore()
    
    var body: some View {
        VStack{
            ForEach(userSettings) { setting in
                
                switch receivedSetting {
                    
                case "description":
                    TextEditor(text: $editedSetting)
                    
                case "email":
                    TextEditor(text: $editedSetting)
                    
                case "name":
                    TextEditor(text: $editedSetting)
                    
                case "address":
                    TextEditor(text: $editedSetting)
                    
                default:
                    TextEditor(text: $receivedSetting)
                }
            
                Button(action: {
                    updateSettings()
                }) {
                    Text("Save")
                }
            }
        }
        .onAppear() {
            listenToFirestore()
        }
    }
    
    
    func listenToFirestore() {
        guard let userUid = Auth.auth().currentUser?.uid else {return}
            
        db.collection("users").document(userUid).addSnapshotListener { snapshot, err in
            guard let snapshot = snapshot else {return}
            
            if let err = err {
                print("Error getting document \(err)")
            } else {
                var userSettings = [UserSettings]()
                
                let data = snapshot.data()
                
                if let description = data?["description"] as? String,
                   let email = data?["email"] as? String,
                   let name = data?["name"] as? String,
                   let address = data?["address"] as? String {
                    let userSetting = UserSettings(description: description,
                                                   email: email,
                                                   name: name,
                                                   address: address)
                    userSettings.append(userSetting)
                    
                    switch receivedSetting {
                        
                    case "description":
                        editedSetting = description
                        
                    case "email":
                        editedSetting = email
                        
                    case "name":
                        editedSetting = name
                        
                    case "address":
                        editedSetting = address
                        
                    default:
                        editedSetting = "failed to load setting"
                    }
                    

                }
                
                self.userSettings = userSettings
            }
            
        }
    }
    
    func updateSettings() {
        guard let userUid = Auth.auth().currentUser?.uid else {return}

        let docRef = db.collection("users").document(userUid)

        docRef.updateData(["\(receivedSetting)": editedSetting]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated!")
            }
        }
    }
    
}

//struct UserSettingsEditView_Previews: PreviewProvider {
 //   static var previews: some View {
 //       UserSettingsEditView()
 //   }
//}
