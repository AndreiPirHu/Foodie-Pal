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
    @State var userMessages = [UserMessages]()
    @State var messagePosition = 0
    var db = Firestore.firestore()
    
    var body: some View {
        VStack(){
            
            Text("Meddelanden")
                .font(.title)
                .frame(width: 500, height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .bold()
            ScrollView{
                    ForEach(userMessages, id :\.self) { message in
                        UserMessageAndDateView(message: message.message ?? "", date: message.date ?? "")
                    }
            }
            HStack{
                
                TextField("Lägg upp ett meddelande", text: $message)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                    
                Spacer()
                Button(action: {
                    uploadMessageToFirestore()
                    message = ""
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.horizontal, 30)
                }
                
            }
            
        }
        .onAppear{
            updateListFromFirestore()
            
        }
    }
    
    
    
    func updateListFromFirestore() {
        //clears messages before loading them again
        messagePosition = 1
        userMessages.removeAll()
        //gets userUid from logged in user
        guard let userUid = Auth.auth().currentUser?.uid else {return}
        db.collection("users").document(userUid).collection("messages").getDocuments { snapshot, err in
            
            guard let snapshot = snapshot else {return}
            
            if let err = err {
                print("Error getting documents \(err)")
            } else {
                for document in snapshot.documents {
                    
                    let result = Result {
                        try document.data(as: UserMessages.self)
                    }
                    switch result {
                    case .success(let userMessage) :
                        
                        userMessages.append(userMessage)
                        //counts current message position based on number of documents
                        messagePosition += 1
                        
                        
                    case .failure(let error) :
                        print("Error decoding item: \(error)")
                    }
                }
                //sort messages by messagePosition
                userMessages.sort(by: { $0.messagePosition ?? 0 < $1.messagePosition ?? 0 })
            }
        }
    }

    
    func uploadMessageToFirestore(){
        //gets userUid from logged in user
        userMessages.removeAll()
        guard let userUid = Auth.auth().currentUser?.uid else {return}
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE d MMM HH:mm"
        
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        
        MessageData["message"] = message
        MessageData["date"] = dateString
        MessageData["messagePosition"] = messagePosition
        
        db.collection("users").document(userUid).collection("messages").addDocument(data: MessageData) { error in
            
            // If there are no errors it displays the new image
            if error == nil {
               print("Message added successfully")
                updateListFromFirestore()
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

struct UserMessageAndDateView: View {
    var message: String = ""
    var date: String = ""
    var body: some View {
        VStack{
            Text(date)
                .font(.custom("", size: 15))
                .foregroundColor(.gray)
            Text(message)
                .padding(10)
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(20)
                .frame(maxWidth: 350 )
            
        }
    }
}
