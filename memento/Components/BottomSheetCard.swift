//
//  BottomSheetCard.swift
//  InfiniteScroll
//
//  Created by Matthew Susko on 2023-08-13.
//

import SwiftUI

struct BottomSheetCard: View {
    var image: Image
    @Environment(\.presentationMode) var presentationMode
    @Binding var showPhotoView: Bool
//    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
            Button {
                self.presentationMode.wrappedValue.dismiss()
                DispatchQueue.main.async {
                    self.showPhotoView = true
                }
            } label: {
                ZStack(alignment: .topTrailing) {
                    ZStack(alignment: .bottom) {
                        image
                            .resizable()
                            .cornerRadius(10)
                            .scaledToFit()
                            .aspectRatio(contentMode: .fit)
                    }
                    .frame(width: 110, height: 170)
                    .shadow(radius: 3)
                }
            }
    }
}

struct BottomSheetCard_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
