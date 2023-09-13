//
//  BottomSheetView.swift
//  InfiniteScroll
//
//  Created by Matthew Susko on 2023-08-12.
//

import SwiftUI

struct BottomSheetView: View {
    @State var date: String
    @Binding var showPhotoView: Bool
    @State var imageList: [Image]
        
    var columns = [
        GridItem.init(.flexible(), alignment: .center),
        GridItem.init(.flexible(), alignment: .center),
        GridItem.init(.flexible(), alignment: .center),
    ]
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Spacer()
                Text(getDateString(date:date))
                    .foregroundColor(.white)
                    .font(.custom("Brother1816-BoldItalic", size: 24))
                    .padding(.all, 5)
                Spacer()
            }
            .background(Color("Accent"))
            .cornerRadius(4)
            
            LazyVGrid(columns: columns, alignment: .center) {
                let displayNumber = imageList.count > 6 ? 6 : imageList.count
                ForEach(0..<displayNumber) { index in
                    BottomSheetCard(image: imageList[index], showPhotoView: $showPhotoView)
                }
            }
        Spacer()
        }
        .padding(.top, 20)
        .padding(.horizontal, 10)
        .background(Color("Background"))
        
    }
    
}

struct BottomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

func getDateString(date: String) -> String {
    let dateFormatter = DateFormatter()
    var localTimeZoneAbbreviation: String { return TimeZone.current.abbreviation() ?? "" }
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.timeZone = TimeZone(abbreviation: localTimeZoneAbbreviation)
    let newDate: Date = dateFormatter.date(from: date)!
    let newFormatter = DateFormatter()
    newFormatter.dateFormat = "EEEE, MMMM d, yyyy"
    return newFormatter.string(from: newDate)
}
