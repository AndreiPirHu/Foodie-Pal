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
    //array of images from database
    @State var retrievedImages = [UIImage]()
    
    let db = Firestore.firestore()
    
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
            
            Divider()
            
            HStack {
                
                //Loop through all the images retrieved and display them
                ForEach(retrievedImages, id: \.self) { image in
                    
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 100, height: 100)
                    
                }
                
                
            }
            
            
            
            
        }.onAppear{
            retrieveImages()
        }
        .sheet(isPresented: $isPickerShowing, onDismiss: nil) {
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
        let path = "images/\(UUID().uuidString).jpg"
        let fileRef = storageRef.child(path)
        
        //upload data
        //force unwrap imageData because data is already guarded
        let uploadTask = fileRef.putData(imageData!, metadata: nil) { metadata, error in
            
            //check for errors
            if error == nil && metadata != nil {
                
                //save reference to document in firestore
                db.collection("images").document().setData(["url":path]) { error in
                    
                    // If there are no errors it displays the new image
                    if error == nil {
                        // add uploaded image to the list of images for display
                        //this only adds the selected image to the array and not directly from firebase. More effective way
                        DispatchQueue.main.async {
                            
                            self.retrievedImages.append(self.selectedImage!)
                            
                            //to make it retrieve images directly from firebase do this instead
                            //self.retrieveImages()
                        }
                        
                        
                        
                        
                        
                    }
                }
                
            }
        }
    }
    
    func retrieveImages() {
        
        //Get data from database
        db.collection("images").getDocuments { snapshot, error in
            
            if error == nil && snapshot != nil {
                
                var paths = [String]()
                
                //loops through all documents
                for doc in snapshot!.documents {
                    
                    // extract file path and adds url to array
                    paths.append(doc["url"] as! String)
                }
                
                //Loop through each file path in paths array and fetch data from storage
                for path in paths {
                    
                    //Get reference to storage
                    let storageRef = Storage.storage().reference()
                    
                    //specify path
                    let fileRef = storageRef.child(path)
                    
                    
                    //Retrieve the data
                    fileRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                        
                        //check for errors
                        //checks that data is not nil
                        if error == nil && data != nil {
                            
                            //create UIImage and put it in image array for display
                            if let image = UIImage(data: data!){
                                
                                DispatchQueue.main.async {
                                    retrievedImages.append(image)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        
        // get image data in storage for each image in reference
        
    }
    
}

struct ImageGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        ImageGalleryView()
    }
}
