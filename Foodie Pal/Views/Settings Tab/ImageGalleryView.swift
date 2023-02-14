//
//  ImageGalleryView.swift
//  Foodie Pal
//
//  Created by Andrei Pirogov on 2023-02-14.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import Firebase

struct ImageGalleryView: View {
    @State var isPickerShowing = false
    @State var selectedImage: UIImage?
    
    var body: some View {
        VStack{
            
            if selectedImage != nil {
                Image(uiImage: selectedImage!)
                    .resizable()
                    .frame(width: 200, height: 200)
            }
            
            Button(action: {
                isPickerShowing = true
            }) {
                Text("Välj en bild")
                    .foregroundColor(.white)
                    .bold()
                    .frame(width: 200,height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                        )
            }
            
            //Upload button
            if selectedImage != nil {
                Button(action: {
                    
                    uploadImage()
                }){
                    Text("Ladda upp bild")
                        .foregroundColor(.white)
                        .bold()
                        .frame(width: 200,height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                            )
                }
            }
            
            
        }.sheet(isPresented: $isPickerShowing, onDismiss: nil) {
            //Image picker
            ImagePicker(selectedImage: $selectedImage, isPickerShowing: $isPickerShowing)
        }
        
        
    }
    
    func uploadImage() {
        
        //make sure an image is selected
        guard selectedImage != nil else{
            return
        }
        // create storage reference
        let storageRef = Storage.storage().reference()
        
        //turn image into data
        let imageData = selectedImage!.jpegData(compressionQuality: 0.8)
        
        //check that it can be converted to data
        guard imageData != nil else{
            return
        }
        //file path and name
        let fileRef = storageRef.child("images/\(UUID().uuidString).jpg")
        
        //upload data
        //force unwrap imageData because data is already guarded
        let uploadTask = fileRef.putData(imageData!, metadata: nil) { metadata, error in
            
            //check for errors
            if error == nil && metadata != nil {
                //save reference to file in firestore
                let db = Firestore.firestore()
                
            }
        }
        
        
    }
    
    
    
}

struct ImageGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        ImageGalleryView()
    }
}
