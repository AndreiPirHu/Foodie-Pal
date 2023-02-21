//
//  SheetExtension.swift
//  Foodie Pal
//
//  Created by Andrei Pirogov on 2023-02-05.
//

import Foundation
import SwiftUI


//extension for the foodtruck sheets in the map view. Special attributes since it is usable while also using the map
extension View{
    @ViewBuilder
    func bottomSheet <Content: View>(
        presentationDetents: Set<PresentationDetent>,
        isPresented: Binding<Bool>,
        dragIndicator: Visibility = .visible,
        sheetCornerRadius: CGFloat?,
        largestUndimmedIndentifier: UISheetPresentationController.Detent.Identifier = .large,
        otherUndimmedIndentifier: UISheetPresentationController.Detent.Identifier = .medium ,
        isTransparentBG: Bool = false,
        //commented away because i want to dismiss it. In apple maps it always stays up at the smallest size
        //interactiveDisabled: Bool = true,
        @ViewBuilder content: @escaping()->Content,
        onDismiss: @escaping ()->()
    )->some View{
        self
            .sheet(isPresented: isPresented){
                onDismiss()
            } content: {
                content()
                    
                    .presentationDetents(presentationDetents)
                    .presentationDragIndicator(dragIndicator)
                //commented away because i want to dismiss it
                    //.interactiveDismissDisabled(interactiveDisabled)
                    .onAppear {
                        
                        guard let windows = UIApplication.shared.connectedScenes.first as?
                                UIWindowScene else{
                            return
                        }
                        
                        if let controller = windows.windows.first?.rootViewController?.presentedViewController, let sheet = controller.presentationController as? UISheetPresentationController{
                            
                            
                            
                            //stops it from changing the tint of other views to gray
                            controller.presentingViewController?.view.tintAdjustmentMode = .normal
                            
                            //makes the sheet act as a large sheet even if it is smaller, makes it usable at all heights
                            sheet.largestUndimmedDetentIdentifier = largestUndimmedIndentifier
                            //sets the corner radius
                            sheet.preferredCornerRadius = sheetCornerRadius
                        }else{
                            print("No controller found")
                        }
                        
                    }
                    
            }
    }
}
