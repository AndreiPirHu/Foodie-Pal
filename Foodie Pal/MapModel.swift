//
//  MapModel.swift
//  Foodie Pal
//
//  Created by Andrei Pirogov on 2023-02-03.
//

import Foundation
import MapKit
import Firebase
import FirebaseFirestoreSwift

struct Address: Codable {
    let data: [Datum]
    
}

struct Datum: Codable {
    let latitude: Double
    let longitude: Double
    let name: String?
}

struct SetMarker: Codable, Identifiable {
    @DocumentID var id: String?
    var address: String
    var title: String
    var email: String
    var description: String
    var category: String
}

struct Location: Identifiable {

    let id = UUID()
    //variables filled by geolocation
    // name is real address with åäö
    let name: String
    let coordinate: CLLocationCoordinate2D
    //variables filled by firebase
    let title: String
    let email: String
    let description: String
    let category: String
    let address: String
    
}

class MapAPI: ObservableObject {
    private let BASE_URL = "http://api.positionstack.com/v1/forward"
    private let API_KEY = "4d2bc8d75cbe90a08afcf5ec845a41a2"
    
    @Published var region: MKCoordinateRegion
    @Published var coordinates = []
    @Published var locations: [Location] = []
    
    
    
    let db = Firestore.firestore()
    
    
    
    init() {
        self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 59.30713183216659, longitude: 18.07499885559082), span:MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        
        
        
        
        
        
        
    }
    
    func getLocation (address: String, delta: Double, title: String, email: String, description: String, category: String) {
        
        //removes all locations so that old locations are removed and only the new address shows
        locations.removeAll()
        
        
        // replaces all spaces with %20 so that the API can read an address easier
        let pAddress = address.replacingOccurrences(of: " ", with: "%20")
        
        
        // URL used to make the request from the API
        let url_string = "\(BASE_URL)?access_key=\(API_KEY)&query=\(pAddress)"
        
        guard let url = URL(string: url_string) else{
            print ("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print(error!.localizedDescription)
                return
            }
            guard let newCoordinates = try? JSONDecoder().decode(Address.self, from: data) else {return}
            
            if newCoordinates.data.isEmpty {
                print ("Could not find the address...")
                return
            }
            
            
            DispatchQueue.main.async {
                let details = newCoordinates.data[0]
                let lat = details.latitude
                let lon = details.longitude
                let name = details.name
                
                self.coordinates = [lat, lon]
                self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), span:MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta))
                
            
                
                let new_location = Location(name: name ?? "Pin", coordinate:  CLLocationCoordinate2D(latitude: lat, longitude: lon), title: title, email: email, description: description, category: category, address: address)
                self.locations.insert(new_location, at: 0)
                
                
                
                print("Successfully loaded the location")
            }
        }
        .resume()
        
    }
    
    
}
