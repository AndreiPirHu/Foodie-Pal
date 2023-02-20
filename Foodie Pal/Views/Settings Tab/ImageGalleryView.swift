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
import FirebaseAuth




struct ImageGalleryView: View {
    @State var isPickerShowing = false
    @State var selectedImage: UIImage?
    @State var downloadedImages = [ImageData]()
    @State var selectedGalleryImageDocID: String?
    @State var selectedGalleryImagePath: String?
    @State var isHeaderImage = false
    var foodTruckName: String = ""
    
    @State var imageExpanderPresented = false
    
    
    
    let db = Firestore.firestore()
    
    var body: some View {
        VStack{
            //If an image is selected it is shown
            if selectedImage != nil {
                Image(uiImage: selectedImage!)
                    .resizable()
                    .frame(width: 200, height: 200)
                
                
                //Toggle for user to set the selected image as headerimage when uploaded
                Button(action: {
                    isHeaderImage.toggle()
                }) {
                    HStack{
                        
                        Text("Använd som header")
                            .foregroundColor(.primary)
                        Image(systemName: isHeaderImage ? "checkmark.square" : "square")
                            .foregroundColor(.primary)
                    }
                   
                }
            }
            //Button to toggle a sheet where user can select an image from library
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
            
            //Upload button shown when image is selected from library
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
                                .fill(Color.green)
                            )
                }
            }
            
            Divider()
            
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack{
                    ForEach(downloadedImages) { image in
                        
                        VStack{
                            Image(uiImage: image.image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                
                                .onTapGesture{
                                    self.selectedGalleryImageDocID = image.docID
                                    self.selectedGalleryImagePath = image.url
                                }
                            
                            
                        }//changes size when selected
                        .frame(width: selectedGalleryImageDocID == image.docID ? 150: 110, height: selectedGalleryImageDocID == image.docID ? 190: 150)
                        .cornerRadius(5)
                    }
                }
            }.padding(10)
            
            //Shows delete button if an image has been selected
            //deletes the selected image from storage and firestore
            if selectedGalleryImagePath != nil {
                Button(action: {
                    DeleteImage(selectedGalleryImagePath: selectedGalleryImagePath ?? "", selectedGalleryImageDocID: selectedGalleryImageDocID ?? "")
                }) {
                    Text("Radera vald bild")
                        .foregroundColor(.white)
                        .bold()
                        .frame(width: 200,height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.red)
                        )
                    
                        .padding(.top, 40)
                        .padding(.bottom, 10)
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
    
    //Uploads image to storage and firestore
    func uploadImage() {
        //make sure a user is logged in
        guard let userUid = Auth.auth().currentUser?.uid else {return}
        
        //make sure an image is selected
        guard selectedImage != nil else{return}
        
        // create storage reference
        let storageRef = Storage.storage().reference()
        
        //turn image into data
        let imageData = selectedImage!.jpegData(compressionQuality: 0.8)
        
        //check that it can be converted to data
        guard imageData != nil else{
            return
        }
        //file path and name
        var docID = UUID().uuidString
        let path = "images/\(docID).jpg"
        let fileRef = storageRef.child(path)
        
        //upload data
        //force unwrap imageData because data is already guarded
        let uploadTask = fileRef.putData(imageData!, metadata: nil) { metadata, error in
            
            //check for errors
            if error == nil && metadata != nil {
                
                
                //if the new image is used as a header it will have a header identifier in the database
                if isHeaderImage == true{
                    db.collection("users").document(userUid).collection("images").document("HeaderImage").getDocument { snapshot, error in
                        if error == nil && snapshot != nil{
                            let data = snapshot!.data()
                            //finds the old headerimage and deletes it so that it does not stay in storage without reference
                            if let deletePath = data?["url"] as? String {
                                let storageRef = Storage.storage().reference()
                                
                                let deleteRef = storageRef.child(deletePath)
                                
                                deleteRef.delete { error in
                                    
                                    //if there was an error it means there was no previous header. Error should still run the code to add a new header
                                    if let error = error {
                                        print("there was an error deleting the header image or there was no previous header image")
                                        
                                        //Starts adding the new chosen header image
                                        db.collection("users").document(userUid).collection("images").document("HeaderImage").setData(["url":path]) { error in
                                            
                                            // If there are no errors it displays the new image
                                            if error == nil {
                                                // add uploaded image to the list of images for display
                                                DispatchQueue.main.async {
                                                    
                                                    //deletes and updates the list to show new header and delete old
                                                    downloadedImages.removeAll()
                                                    
                                                    self.retrieveImages()
                                                }
                                            }
                                        }
                                    }else{
                                        
                                        //if there was a previous header no errors are detected and the new header gets added
                                        db.collection("users").document(userUid).collection("images").document("HeaderImage").setData(["url":path]) { error in
                                            
                                            // If there are no errors it displays the new image
                                            if error == nil {
                                                // add uploaded image to the list of images for display
                                                DispatchQueue.main.async {
                                                    
                                                    downloadedImages.removeAll()
                                                    //to make it retrieve images directly from firebase do this instead
                                                    self.retrieveImages()
                                                }
                                            }
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                    
                    
                    //end of isheader code
                }else {
                   //if the uploaded image is not a header, it uploads normally
                    db.collection("users").document(userUid).collection("images").document(docID).setData(["url":path]) { error in
                                       
                                       // If there are no errors it displays the new image
                                       if error == nil {
                                           // add uploaded image to the list of images for display
                                           DispatchQueue.main.async {
                                               
                                               downloadedImages.removeAll()
                                               //to make it retrieve images directly from firebase do this instead
                                               self.retrieveImages()
                                           }
                                       }
                                   }
                }
            }
        }
    }
    
    
    
    
    func retrieveImages() {
        downloadedImages.removeAll()
        guard let userUid = Auth.auth().currentUser?.uid else {return}
        //Get data from database
        db.collection("users").document(userUid).collection("images").getDocuments { snapshot, error in
            
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
                                    
                                    //removes images/ and .jpg to give the correct docID
                                    let docID = path.replacingOccurrences(of: "images/", with: "").replacingOccurrences(of: ".jpg", with: "")
                                    
                                    DispatchQueue.main.async {
                                        
                                        let downloadedImage = ImageData(docID: docID, url: path, image: image)
                                        
                                        downloadedImages.append(downloadedImage)
                                        
                                    }
                                    
                                }
                            }
                        }
                    }
            }
        }
    }
    
   
    //Deletes the selected image from storage and firestore
    func DeleteImage(selectedGalleryImagePath: String, selectedGalleryImageDocID: String){
        guard let userUid = Auth.auth().currentUser?.uid else {return}
        
        let storageRef = Storage.storage().reference()
        
        //specify path
        let deleteRef = storageRef.child(selectedGalleryImagePath)
        
        deleteRef.delete { error in
            if let error = error {
                print("uh-oh, an error occurred while deleting")
            }else{
                
                
                //if successful deletes from firestore too
                db.collection("users").document(userUid).collection("images").document(selectedGalleryImageDocID).delete()
                
                downloadedImages.removeAll()
                //reload images after removing
                self.retrieveImages()
                print("File was successfully deleted!")
            }
            
        }
    }
    
    
    
    
    
    
    
    
}



struct ImageGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        ImageGalleryView()
    }
}
