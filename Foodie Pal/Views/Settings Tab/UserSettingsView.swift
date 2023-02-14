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
    @State var isLoggedOut = false
    
    @State var selectedTime = Date()
    

    
    
    
    
    
    
    
    
    
    var sendSetting = ["description", "email", "name", "address"]
    
    
    let db = Firestore.firestore()
    
    var body: some View {
        
            VStack{
                ForEach(userSettings) { setting in
                    
                    Text("Hello, \(setting.name)")
                        //.padding(.bottom, 10)
                        .padding(.top, 30)
                        .font(.title)
                    
                    Spacer()
                    
                    NavigationView{
                        List{
                            NavigationLink(destination: UserSettingsEditView(receivedSetting: sendSetting[0])){
                                ListedSettingView(setting: "Beskrivning:", settingText: setting.description)
                            }
                            //NavigationLink(destination: UserSettingsEditView(receivedSetting: sendSetting[1])){
                            //    ListedSettingView(setting: "Email:", settingText: setting.email)
                            //}
                            NavigationLink(destination: UserSettingsEditView(receivedSetting: sendSetting[2])){
                                ListedSettingView(setting: "Namn:", settingText: setting.name)
                            }
                            NavigationLink(destination: UserSettingsEditView(receivedSetting: sendSetting[3])){
                                ListedSettingView(setting: "Adress:", settingText: setting.address)
                            }
                            ListedScheduleView(weekday: "Mån", openingTime: setting.schedMonOpen , closingTime: setting.schedMonClose, weekdayOpening: "schedMonOpen", weekdayClosing: "schedMonClose")
                            
                            ListedScheduleView(weekday: "Tis", openingTime: setting.schedTueOpen , closingTime: setting.schedTueClose, weekdayOpening: "schedTueOpen", weekdayClosing: "schedTueClose")
                            
                            ListedScheduleView(weekday: "Ons", openingTime: setting.schedWedOpen , closingTime: setting.schedWedClose, weekdayOpening: "schedWedOpen", weekdayClosing: "schedWedClose")
                            
                            ListedScheduleView(weekday: "Tors", openingTime: setting.schedThuOpen , closingTime: setting.schedThuClose, weekdayOpening: "schedThuOpen", weekdayClosing: "schedThuClose")
                            
                            ListedScheduleView(weekday: "Fre", openingTime: setting.schedFriOpen , closingTime: setting.schedFriClose, weekdayOpening: "schedFriOpen", weekdayClosing: "schedFriClose")
                            
                            ListedScheduleView(weekday: "Lör", openingTime: setting.schedSatOpen , closingTime: setting.schedSatClose, weekdayOpening: "schedSatOpen", weekdayClosing: "schedSatClose")
                            
                            ListedScheduleView(weekday: "Sön", openingTime: setting.schedSunOpen , closingTime: setting.schedSunClose, weekdayOpening: "schedSunOpen", weekdayClosing: "schedSunClose")
                            
                        }.scrollContentBackground(.hidden)
                            .navigationTitle("Inställningar")
                    }
                    
                    
                }
                
                Button(action: {
                    //goto images page
                }) {
                    Text("Bildgalleri")
                        .foregroundColor(.white)
                        .bold()
                        .frame(width: 200,height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.green)
                        )
                        
                        .padding(.bottom, 40)
                }
                
                Button(action: {
                    logOut()
                }) {
                    Text("Logga ut")
                        .foregroundColor(.white)
                        .bold()
                        .frame(width: 200,height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.red)
                        )
                        
                        .padding(.bottom, 40)
                }
                
                
            }
            .onAppear() {
                listenToFirestore()
            }
            .navigationDestination(isPresented: $isLoggedOut ) {
                SettingsView().navigationBarBackButtonHidden(true)
            }
    }
    
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    func logOut() {
        do {
            try Auth.auth().signOut()
            isLoggedOut = true
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
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
                   let address = data?["address"] as? String,
                   let schedMonOpen = data?["schedMonOpen"] as? String,
                   let schedMonClose = data?["schedMonClose"] as? String,
                    let schedTueOpen = data?["schedTueOpen"] as? String,
                    let schedTueClose = data?["schedTueClose"] as? String,
                    let schedWedOpen = data?["schedWedOpen"] as? String,
                    let schedWedClose = data?["schedWedClose"] as? String,
                   let schedThuOpen = data?["schedThuOpen"] as? String,
                   let schedThuClose = data?["schedThuClose"] as? String,
                   let schedFriOpen = data?["schedFriOpen"] as? String,
                   let schedFriClose = data?["schedFriClose"] as? String,
                   let schedSatOpen = data?["schedSatOpen"] as? String,
                   let schedSatClose = data?["schedSatClose"] as? String,
                   let schedSunOpen = data?["schedSunOpen"] as? String,
                   let schedSunClose = data?["schedSunClose"] as? String {
                    let userSetting = UserSettings(description: description,
                                                   email: email,
                                                   name: name,
                                                   address: address,
                                                   schedMonOpen: schedMonOpen,
                                                   schedMonClose: schedMonClose,
                                                   schedTueOpen: schedTueOpen,
                                                   schedTueClose: schedTueClose,
                                                   schedWedOpen: schedWedOpen,
                                                   schedWedClose: schedWedClose,
                                                   schedThuOpen: schedThuOpen,
                                                   schedThuClose: schedThuClose,
                                                   schedFriOpen: schedFriOpen,
                                                   schedFriClose: schedFriClose,
                                                   schedSatOpen: schedSatOpen,
                                                   schedSatClose: schedSatClose,
                                                   schedSunOpen: schedSunOpen,
                                                   schedSunClose: schedSunClose)
                    userSettings.append(userSetting)
                    
                }
                
                self.userSettings = userSettings
            }
            
        }
    }
}



struct ListedSettingView: View {
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


struct ListedScheduleView: View {
    var weekday: String
    @State var openingTime: String
    
    @State var closingTime: String
    
    var weekdayOpening: String
    var weekdayClosing: String
    
    let times = ["Stängt","00:30", "01:00", "01:30", "02:00", "02:30", "03:00", "03:30", "04:00", "04:30", "05:00", "05:30", "06:00", "06:30", "07:00", "07:30", "08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00", "21:30", "22:00", "22:30", "23:00", "23:30", "00:00"]
    
    var body: some View {
        HStack{
            Text(weekday)
            
            Spacer()
            
            Picker("Välj en tid", selection: $openingTime){
                ForEach(times, id: \.self) { time in
                    Text(time)
                }
            }
            .frame(width: 100)
            .labelsHidden()
            //triggers the updateschedule func when a change is made
            .onReceive([self.openingTime].publisher.first()) { (value) in
                            self.updateSchedule()
                        }
            
            Text("-")
            
            Picker("Välj en tid", selection: $closingTime){
                ForEach(times, id: \.self) { time in
                    Text(time)
                }
            }
            .frame(width: 100)
            .labelsHidden()
            //triggers the updateschedule func when a change is made
            .onReceive([self.closingTime].publisher.first()) { (value) in
                            self.updateSchedule()
                        }
                
        }
        
        
        
        
    }
    //updates the schedule times in firestore when they are changed in the picker
    func updateSchedule() {
        let db = Firestore.firestore()
        guard let userUid = Auth.auth().currentUser?.uid else {return}

        let docRef = db.collection("users").document(userUid)

        docRef.updateData(["\(weekdayOpening)": openingTime,
                           "\(weekdayClosing)": closingTime ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated!")
            }
        }
    }
    
    
}





struct UserSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        UserSettingsView()
    }
}


