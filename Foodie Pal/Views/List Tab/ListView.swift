//
//  ListView.swift
//  Foodie Pal
//
//  Created by Andrei Pirogov on 2023-01-27.
//

import SwiftUI
import Firebase
import FirebaseStorage

struct ListView: View {
    @State var foodTruckTemplate = [FoodTrucks]()
    @State var foodTrucks = [FoodTrucksList]()
    
    let db = Firestore.firestore()
    
    var body: some View {
        VStack(){
            
            NavigationView{
                VStack(alignment: .leading){
                    Text("Food Trucks")
                        .font(.custom("Avenir-Heavy", size: 40))
                        .fontWeight(.heavy)
                        .padding(.horizontal, 45)
                        .offset(y: 35)
                        
                    List(foodTrucks, id :\.self) { foodTruck in
                        
                        NavigationLink(destination: FoodTruckInfoView(foodTruckUid: foodTruck.uid ?? "") ) {
                            FoodTruckRowView(foodTruck: foodTruck)
                        }
                        
                        
                    }.scrollContentBackground(.hidden)
                        .frame(width: 450)
                }
            }
        }
        .onAppear{
            updateListFromFirestore()
        }
        
    }
   
    
    func updateListFromFirestore() {
        db.collection("users").addSnapshotListener { snapshot, err in
            guard let snapshot = snapshot else {return}
            
            if let err = err {
                print("Error getting document \(err)")
            } else {
                for document in snapshot.documents {
                    
                    let result = Result {
                        try document.data(as: FoodTrucks.self)
                    }
                    switch result {
                    case .success(let foodTruckTemp) :
                        foodTruckTemplate.append(foodTruckTemp)
                        
                            downloadHeaderImage(for: foodTruckTemp)
                        
                        
                        
                        
                    case .failure(let error) :
                        print("Error decoding item: \(error)")
                    }
                }
            }
        }
    }

    func downloadHeaderImage(for foodTruck: FoodTrucks){
        foodTrucks.removeAll()
        print("Började funktionen \(foodTruck.uid) ")
        
        db.collection("users").document(foodTruck.uid).collection("images").document("HeaderImage").getDocument() { snapshot, error in
            
            print("fick rätt uid \(foodTruck.uid)" )
            if error == nil && snapshot != nil {
                
                DispatchQueue.main.async {
                
                if let snapshot = snapshot, snapshot.exists {
                    
                    if let fieldValue = snapshot.get("url") as? String {
                        print("fick rätt url \(fieldValue)" )
                        let path = fieldValue
                        let storageRef = Storage.storage().reference()
                        let fileRef = storageRef.child(path)
                        print("fick rätt url \(path)" )
                        fileRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                            
                            if error == nil && data != nil{
                                
                                DispatchQueue.main.async {
                                    
                                    if let image = UIImage(data: data!){
                                        
                                        DispatchQueue.main.async {
                                            
                                            print("fick in bild \(foodTruck.name)")
                                            
                                            
                                            let new_foodTruck = FoodTrucksList(name: foodTruck.name, category: foodTruck.category, description: foodTruck.description, uid: foodTruck.uid, image: image)
                                            
                                            self.foodTrucks.append(new_foodTruck)
                                            
                                            print(new_foodTruck.name)
                                        }
                                    }
                                }
                            }
                            if error != nil {
                                print("there was an error retrieving \(foodTruck.name) image")
                                print(error)
                            }
                        }
                    } else {
                        print("Field value could not be retrieved as a string.")
                        print("No foodtrucks were inserted ")
                    }
                }
            }
            }
        }
        
    
        
    }
    
    
    
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}

struct FoodTruckRowView: View {
    var foodTruck = FoodTrucksList(name: "", category: "", description: "", uid: "", image: UIImage(systemName:"square.3.layers.3d.down.right.slash"))
    
    var body: some View {
        
        VStack(alignment: .leading){
            HStack{
                if let image = foodTruck.image {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 125, height: 100)
                        .cornerRadius(10)
                        .aspectRatio(contentMode: .fill)
                }else{
                    //if there are problmes loading the image a sfsymbol is shown instead
                    Image(systemName: "square.3.layers.3d.down.right.slash")
                        .resizable()
                        .frame(width: 125, height: 100)
                        .cornerRadius(10)
                        .aspectRatio(contentMode: .fill)
                }
                
                VStack(alignment: .leading){
                    HStack{
                        Text(foodTruck.name ?? "")
                            .fontWeight(.medium)
                            .font(.title3)
                    }
                    Text(foodTruck.category ?? "")
                        .foregroundColor(.gray)
                        .font(.custom("", size: 15))
                    
                    Text((foodTruck.description?.prefix(50) ?? "") + "...")
                        .padding(.top, 5)
                    
                }
                
            }
            
        }
        .padding(.bottom, 10)
    }
}
