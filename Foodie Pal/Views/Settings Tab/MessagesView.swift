//
//  MessagesView.swift
//  Foodie Pal
//
//  Created by Andrei Pirogov on 2023-02-18.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct MessagesView: View {
    @State var message: String = ""
    var db = Firestore.firestore()
    
    var body: some View {
        VStack(){
            
            Text("Meddelanden")
                .font(.title)
                .frame(width: 500, height: 70)
                .background(Color.blue)
                .foregroundColor(.white)
                .bold()
            Spacer()
            VStack{
                Text("tors 20 nov. 12:39")
                    .font(.custom("", size: 15))
                    .foregroundColor(.gray)
                Text("Från och med måndag vecka 7 kommer vi vara på Rålambshovsparken!")
                    .padding(10)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(20)
                    .frame(maxWidth: 350 )
                
            }
            HStack{
                
                TextField("Lägg upp ett meddelande", text: $message)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                    
                Spacer()
                Button(action: {
                    uploadMessageToFirestore()
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.horizontal, 30)
                }
                
            }
            
        }
    }
    
    func uploadMessageToFirestore(){
        //gets userUid from logged in user
        guard let userUid = Auth.auth().currentUser?.uid else {return}
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE d MMM HH:mm"
        
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        
        MessageData["message"] = message
        MessageData["date"] = dateString
        
        db.collection("users").document(userUid).collection("messages").addDocument(data: MessageData) { error in
            
            // If there are no errors it displays the new image
            if error == nil {
               print("Message added successfully")
                
            }else{
                print(error)
            }
        }
        
    }
    
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
    }
}
