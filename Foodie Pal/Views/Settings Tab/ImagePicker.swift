//
//  ImagePicker.swift
//  Foodie Pal
//
//  Created by Andrei Pirogov on 2023-02-14.
//

import Foundation
import UIKit
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var selectedImage: UIImage?
    @Binding var isPickerShowing: Bool
    
    func makeUIViewController(context: Context) -> some UIViewController {
        
        //picks out an image from the photo library on the phone
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = context.coordinator
        
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    
    }
    
    // tells the context.coordinator which coordinator to use
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
}

class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //allows us to get the image picked through imagepicker
    var parent: ImagePicker
    
    init(_ picker: ImagePicker) {
        self.parent = picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //get the picked image
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            DispatchQueue.main.async {
                self.parent.selectedImage = image
            }
        }
        
        //when the image has been selected the sheet is removed
        parent.isPickerShowing = false
        
        //run code when the user has selected an image
    }
    
    
    //what happens when the picker window gets cancelled
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        parent.isPickerShowing = false
        
    }
}
