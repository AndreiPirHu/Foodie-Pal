//
//  FoodTruckInfoView.swift
//  Foodie Pal
//
//  Created by Andrei Pirogov on 2023-02-18.
//

import SwiftUI
import Firebase
import FirebaseStorage
import MapKit

struct FoodTruckInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var scheduleIsExpanded = false
    @State var imageExpanderPresented = false
    @State var downloadedImages = [ImageData]()
    @State var userMessages = [UserMessages]()
    @State var foodTruck = FoodTrucks()
    //gets uid from ListView
    var foodTruckUid: String?
    var db = Firestore.firestore()
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading){
                Text(foodTruck.title)
                    .font(.title)
                    .bold()
                
                Text(foodTruck.category)
                    .padding(.bottom, 20)
                
                // image gallery
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack{
                        ForEach(downloadedImages) { image in
                            
                            imagePreView(image: image.image)
                                .padding(-1)

                        }
                    }
                    
                    //sheet for the expanded image view
                }.sheet(isPresented: $imageExpanderPresented, onDismiss: {imageExpanderPresented = false}) {
                    ExpandedImageGallerySheetView(imageExpanderPresented: $imageExpanderPresented, foodTruckName: foodTruck.name, downloadedImages: downloadedImages)
                }// end of sheet for image gallery expander
                //ontap opens up the expanded image view
                .onTapGesture {
                    imageExpanderPresented = true
                }
                .padding(.bottom, 20)
                
                
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("ÖPPETTIDER")
                            .font(.custom("", size: 14))
                            .padding(.top, 10)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        Image(systemName: scheduleIsExpanded ? "chevron.up" : "chevron.down")
                    }
                    .onTapGesture {
                        self.scheduleIsExpanded.toggle()
                    }
                    
                    Divider()
                        .background(.gray)
                        .frame(width: 340)
                    
                    if scheduleIsExpanded {
                        VStack{
                            HorizontalScheduleView(weekday: "Mån", openingTime: foodTruck.schedMonOpen, closingTime: foodTruck.schedMonClose)
                            HorizontalScheduleView(weekday: "Tis", openingTime: foodTruck.schedTueOpen, closingTime: foodTruck.schedTueClose)
                            HorizontalScheduleView(weekday: "Ons", openingTime: foodTruck.schedWedOpen, closingTime: foodTruck.schedWedClose)
                            HorizontalScheduleView(weekday: "Tors", openingTime: foodTruck.schedThuOpen, closingTime: foodTruck.schedThuClose)
                            HorizontalScheduleView(weekday: "Fre", openingTime: foodTruck.schedFriOpen, closingTime: foodTruck.schedFriClose)
                            HorizontalScheduleView(weekday: "Lör", openingTime: foodTruck.schedSatOpen, closingTime: foodTruck.schedSatClose)
                            HorizontalScheduleView(weekday: "Sön", openingTime: foodTruck.schedSunOpen, closingTime: foodTruck.schedSunClose)
                        }
                        
                    }
                    
                    Text("ADRESS")
                        .font(.custom("", size: 14))
                        .padding(.top, 30)
                        .foregroundColor(.gray)
                    
                    Divider()
                        .background(.gray)
                        .frame(width: 340)
                    
                    Button(action: {
                                openInMaps()
                    }){
                        HStack {
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .foregroundColor(Color.blue)
                            
                                .frame(height: 30)
                                .overlay(
                                    Text(foodTruck.address).foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 16)
                                )
                            
                            Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .offset(x: -40)
                                .foregroundColor(.white)
                            
                        }
                        .padding(.bottom, 20)
                    }
                    
                    
                    
                    Text("BESKRIVNING")
                        .font(.custom("", size: 14))
                        .padding(.top, 30)
                        .bold()
                        .foregroundColor(.gray)
                    Divider()
                        .background(.gray)
                        .frame(width: 340)
                    
                    Text(foodTruck.description)
                }
                Text("SENASTE NYTT")
                    .font(.custom("", size: 14))
                    .padding(.top, 30)
                    .bold()
                    .foregroundColor(.gray)
                Divider()
                ScrollView{
                    ForEach(userMessages, id :\.self) { message in
                        UserMessageAndDateView(message: message.message ?? "", date: message.date ?? "")
                    }
                }
                .frame(height: 200)
                
                
                
                Spacer()
            }.onAppear{
                //fetches truck info based on clicked truck
                getFoodTruckInfo()
                //fetches images based on clicked truck
                downloadImages()
                //removes all messages
                userMessages.removeAll()
                //fetches all messages based on clicked truck
                updateMessagesFromFirestore()
            }
            .padding()
            .padding(.top, 15)
        }
        .navigationBarBackButtonHidden()
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.backward.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(.vertical, 5)
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    func openInMaps(){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(foodTruck.address) { (placemarks, error) in
                   if let error = error {
                       print("Geocoding error: \(error.localizedDescription)")
                   } else if let placemark = placemarks?.first {
                       let mapItem = MKMapItem(placemark: MKPlacemark(placemark: placemark))
                       mapItem.name = foodTruck.address
                       mapItem.openInMaps()
                   }
               }
    }
    
    func updateMessagesFromFirestore() {
        //gets userUid from clicked truck or else it stops the function
        guard let uid = foodTruckUid else {return}
        //gets userUid from clicked truck
        
        db.collection("users").document(uid).collection("messages").addSnapshotListener { snapshot, err in

            
            guard let snapshot = snapshot else {return}
            
            if let err = err {
                print("Error getting documents \(err)")
            } else {
                //clears messages before loading them again
                userMessages.removeAll()
                for document in snapshot.documents {
                    
                    let result = Result {
                        try document.data(as: UserMessages.self)
                    }
                    switch result {
                    case .success(let userMessage) :
                        
                        userMessages.append(userMessage)
                        
                    case .failure(let error) :
                        print("Error decoding item: \(error)")
                    }
                }
                //sort messages by messagePosition
                userMessages.sort(by: { $0.messagePosition ?? 0 > $1.messagePosition ?? 0 })
            }
        }
    }
    
    
    func getFoodTruckInfo() {
        guard let uid = foodTruckUid else {return}
        
        db.collection("users").document(uid).getDocument { snapshot, error in
            
            if error == nil && snapshot != nil {
                
                if let snapshot = snapshot, snapshot.exists {
                    
                    let result = Result{
                        try snapshot.data(as: FoodTrucks.self )
                    }
                    switch result {
                    case .success(let foodTruckInfo):
                        
                        self.foodTruck = foodTruckInfo
                        
                    case .failure(let error):
                        print("Error decoding foodtruck: \(error)")
                    }
                    
                }
            }else {
                print("Error retrieving document : \(error)")
            }
        }
    }
    
    
    //downloads images from storage to show in  imageView on the sheet
    func downloadImages() {
        guard let uid = foodTruckUid else {return}
        downloadedImages.removeAll()
        db.collection("users").document(uid).collection("images").getDocuments { snapshot, error in
            
            if error == nil && snapshot != nil {
                
                //array for all the fetched paths from documents
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
    
    
    
}
        


struct FoodTruckInfoView_Previews: PreviewProvider {
    static var previews: some View {
        FoodTruckInfoView()
    }
}
