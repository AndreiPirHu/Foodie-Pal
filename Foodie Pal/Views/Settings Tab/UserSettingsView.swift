//
//  UserSettingsView.swift
//  Foodie Pal
//
//  Created by Andrei Pirogov on 2023-01-28.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct UserSettingsView: View {
    @State var userSettings = [UserSettings]()
    var sendSetting = ["description", "email", "name", "address"]
    
    let db = Firestore.firestore()
    
    var body: some View {
        
            VStack{
                ForEach(userSettings) { setting in
                    
                    NavigationView{
                        List{
                            NavigationLink(destination: UserSettingsEditView(receivedSetting: sendSetting[0])){
                                ExtractedView(setting: "Beskrivning:", settingText: setting.description)
                            }
                            NavigationLink(destination: UserSettingsEditView(receivedSetting: sendSetting[1])){
                                ExtractedView(setting: "Email:", settingText: setting.email)
                            }
                            NavigationLink(destination: UserSettingsEditView(receivedSetting: sendSetting[2])){
                                ExtractedView(setting: "Namn:", settingText: setting.name)
                            }
                            NavigationLink(destination: UserSettingsEditView(receivedSetting: sendSetting[3])){
                                ExtractedView(setting: "Adress:", settingText: setting.address)
                            }
                        }
                    }
                    .navigationTitle("Hello, \(setting.name)")
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
                    
                }
                
                self.userSettings = userSettings
            }
            
        }
    }
}



struct ExtractedView: View {
    var setting : String
    var settingText : String
    
    
    var body: some View {
        HStack{
            Text(setting)
            Spacer()
            Text(settingText.prefix(7) + "...")
        }
    }
}



struct UserSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        UserSettingsView()
    }
}


