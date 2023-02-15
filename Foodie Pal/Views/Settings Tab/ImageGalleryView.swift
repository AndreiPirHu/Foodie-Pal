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



struct ImageData: Hashable {
    let docID: String
    let url: String
    let image: UIImage
}



struct ImageGalleryView: View {
    @State var isPickerShowing = false
    @State var selectedImage: UIImage?
    //array of images from database
    @State var downloadedImages = [(docID: String, url: String, image: UIImage)]()
    @State var selectedGalleryImageDocID: String?
    @State var selectedGalleryImagePath: String?
    
    
    
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
            
            //Upload button shown when image is selected
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
            
            HStack {
                
               //Loops through all the images retrieved and displays them
                let imageDataArray = downloadedImages.map { ImageData(docID: $0.docID, url: $0.url, image: $0.image) }
                ForEach(imageDataArray, id :\.self) { image in
                    Image(uiImage: image.image)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .scaleEffect(selectedGalleryImageDocID == image.docID ? 1: 0.7)
                        .onTapGesture{
                            self.selectedGalleryImageDocID = image.docID
                            self.selectedGalleryImagePath = image.url
                        }
                        .padding(.top, 10)
                }
            }
            
            //Shows delete button if an image has been selected
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
                }
            }
        }.onAppear{
            retrieveImages()
            //downloadImages()
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
        let docID = UUID().uuidString
        let path = "images/\(docID).jpg"
        let fileRef = storageRef.child(path)
        
        //upload data
        //force unwrap imageData because data is already guarded
        let uploadTask = fileRef.putData(imageData!, metadata: nil) { metadata, error in
            
            //check for errors
            if error == nil && metadata != nil {
                
                //save reference to document in firestore
                db.collection("images").document(docID).setData(["url":path]) { error in
                    
                    // If there are no errors it displays the new image
                    if error == nil {
                        // add uploaded image to the list of images for display
                        //this only adds the selected image to the array and not directly from firebase. More effective way
                        DispatchQueue.main.async {
                            
                           // self.retrievedImages.append(self.selectedImage!)
                            
                            downloadedImages.removeAll()
                            //to make it retrieve images directly from firebase do this instead
                            self.retrieveImages()
                            
                            
                           // self.downloadImages()
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
                                    
                                    //removes images/ and .jpg to give the correct docID
                                    let docID = path.replacingOccurrences(of: "images/", with: "").replacingOccurrences(of: ".jpg", with: "")
                                    
                                    DispatchQueue.main.async {
                                        
                                        downloadedImages.append((docID, path, image))
                                        
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
        let storageRef = Storage.storage().reference()
        
        //specify path
        let deleteRef = storageRef.child(selectedGalleryImagePath)
        
        deleteRef.delete { error in
            if let error = error {
                print("uh-oh, an error occurred while deleting")
            }else{
                //if successful deletes from firestore too
                db.collection("images").document(selectedGalleryImageDocID).delete()
                
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
