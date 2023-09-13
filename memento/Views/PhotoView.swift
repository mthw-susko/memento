//
//  PhotoView.swift
//  InfiniteScroll
//
//  Created by Matthew Susko on 2023-08-12.
//

import SwiftUI

struct PhotoView: View {
    var imageList: [Image] = []
    var dateString: String = "Tuesday, July 21 2023"
    var timeList: [String] = []
    @Binding var showPhotoView: Bool
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            VStack {
                HStack {
                    Spacer()
                    Text(getDateString(date:dateString))
                        .font(.custom("Brother1816-BoldItalic", size: 24))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.all, 5)
                .background(Color("Accent"))
                .cornerRadius(4)
                
                ForEach(0..<imageList.count) { index in
                    BigPhoto(image:imageList[index], time: timeList[index])
                }
                Spacer()
            }
            .padding(.all, 10)
        }
        .background(Color("Background"))
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action : {
            self.mode.wrappedValue.dismiss()
            showPhotoView = false
        }){
            Image(systemName: "arrow.left")
        })
    }
}

struct PhotoView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
