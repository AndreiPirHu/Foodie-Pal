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
    @Environment(\.presentationMode) var presentationMode
    @State var userSettings = [UserSettings]()
    @State var receivedSetting : String
    
    
    @State var editedSetting : String = ""
    
    let db = Firestore.firestore()
    
    var body: some View {
        VStack{
          
                
                switch receivedSetting {
                    
                case "description":
                    Text("Beskrivning")
                        .font(.title)
                        .bold()
                    TextEditor(text: $editedSetting)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .padding(.vertical, 60)
                case "email":
                    Text("Email")
                        .font(.title)
                        .bold()
                    TextEditor(text: $editedSetting)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .padding(.vertical, 60)
                    
                case "title":
                    Text("Namn")
                        .font(.title)
                        .bold()
                    TextEditor(text: $editedSetting)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .padding(.vertical, 60)
                    
                case "address":
                    Text("Adress")
                        .font(.title)
                        .bold()
                    TextEditor(text: $editedSetting)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .padding(.vertical, 60)
                    
                default:
                    TextEditor(text: $receivedSetting)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .padding(.vertical, 60)
                }
                Button(action: {
                    updateSettings()
                    //goes back to previous view
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save")
                        .foregroundColor(.white)
                        .bold()
                        .frame(width: 200,height: 40)
                        .background(RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.blue)
                        )
                        .padding(.bottom, 20)
                }
          
        }
        .onAppear() {
            listenToFirestore()
        }
        .navigationBarBackButtonHidden()
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.backward.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(.top, 5)
                        .foregroundColor(.gray)
                }
            }
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
                   // name is "title" in firestore since name is not used
                   let name = data?["title"] as? String,
                   let address = data?["address"] as? String {
                    let userSetting = UserSettings(description: description,
                                                   email: email,
                                                   name: name,
                                                   address: address)
                    userSettings.append(userSetting)
                    //checks which setting was pressed in previous view
                    switch receivedSetting {
                        
                    case "description":
                        editedSetting = description
                        
                    case "email":
                        editedSetting = email
                        
                    case "title":
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
