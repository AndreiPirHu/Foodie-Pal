//
//  SettingsView.swift
//  Foodie Pal
//
//  Created by Andrei Pirogov on 2023-01-27.
//

import SwiftUI
import Firebase

struct SettingsView: View {
    @State var email = ""
    @State var password = ""
    @State var errorMessage = ""
    @State var showLoginErrorAlert = false
    
    @State var isLoggedIn = false
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 20) {
                Text("Logga in")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .offset(y:-150)
                
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
                    .foregroundColor(.primary)
                
                SecureField("Lösenord", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
                    .foregroundColor(.primary)
                
                Button(action: {
                    login()
                }) {
                    Text("Logga in")
                        .foregroundColor(.white)
                        .bold()
                        .frame(width: 200,height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .padding(.top)
                .offset(y: 10)
                
                //Add function to recover password
               // Button(action: {
                    //recover forgotten password
                    
                //}) {
                  //  Text("Forgot your password?")
                    //    .bold()
                      //  .foregroundColor(.blue)
                    
                //}
                
            }
            .navigationDestination(isPresented: $isLoggedIn) {
                UserSettingsView().navigationBarBackButtonHidden(true)
                
            }
            .alert(isPresented: $showLoginErrorAlert){
                Alert(title: Text("Inloggning misslyckades"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password){ result, error in
            if error != nil {
                //översätter errors från firestore till svenska och ger ut dem som alert
                switch error!.localizedDescription {
                    
                case "The password is invalid or the user does not have a password.":
                    print("Lösenordet är felaktigt")
                    errorMessage = "Lösenordet är felaktigt"
                    
                case "There is no user record corresponding to this identifier. The user may have been deleted.":
                    print("Hittar ingen användare med denna mailadress")
                    errorMessage = "Det finns ingen användare med denna mailadress"
                    
                case "The email address is badly formatted.":
                    print("Mailadressen är dåligt formatterad")
                    errorMessage = "Mailadressen är dåligt formatterad"
                    
                default:
                    print("Det uppstod ett problem när du försökte logga in")
                    errorMessage = "Det uppstod ett problem när du försökte logga in"
                }
                
                print(error!.localizedDescription)
               
                self.showLoginErrorAlert = true
                
                    
                
                
            }else {
                isLoggedIn = true
                
            }
            
             
        }
    }
}



struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
