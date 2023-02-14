//
//  SheetExtension.swift
//  Foodie Pal
//
//  Created by Andrei Pirogov on 2023-02-05.
//

import Foundation
import SwiftUI

extension View{
    @ViewBuilder
    func bottomSheet <Content: View>(
        presentationDetents: Set<PresentationDetent>,
        isPresented: Binding<Bool>,
        dragIndicator: Visibility = .visible,
        sheetCornerRadius: CGFloat?,
        largestUndimmedIndentifier: UISheetPresentationController.Detent.Identifier = .large,
        isTransparentBG: Bool = false,
        interactiveDisabled: Bool = true,
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
                    //.interactiveDismissDisabled(interactiveDisabled)
                    .onAppear {
                        
                        guard let windows = UIApplication.shared.connectedScenes.first as?
                                UIWindowScene else{
                            return
                        }
                        
                        if let controller = windows.windows.first?.rootViewController?.presentedViewController, let sheet = controller.presentationController as? UISheetPresentationController{
                            
                            sheet.largestUndimmedDetentIdentifier = largestUndimmedIndentifier
                            sheet.preferredCornerRadius = sheetCornerRadius
                        }else{
                            print("No controller found")
                        }
                        
                    }
            }
    }
}
