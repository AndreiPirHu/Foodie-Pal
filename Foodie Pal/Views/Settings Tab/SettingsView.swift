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
                
                SecureField("Lösenord", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
                
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
                
                Button(action: {
                    //recover forgotten password
                    
                }) {
                    Text("Forgot your password?")
                        .bold()
                    
                }
                
            }
            .navigationDestination(isPresented: $isLoggedIn) {
                UserSettingsView().navigationBarBackButtonHidden(true)
            }
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password){ result, error in
            if error != nil {
                print(error!.localizedDescription)
            }else {
               // print("login successful \(Auth.auth().currentUser?.uid)")
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
