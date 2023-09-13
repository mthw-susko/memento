//
//  CalendarCell.swift
//  InfiniteScroll
//
//  Created by Matthew Susko on 2023-08-12.
//

import SwiftUI

struct CalendarCell: View {
    @EnvironmentObject var album: PhotoManager
    var beforeImageURL:String
    var afterImageURL:String
    var date:String
    var height:CGFloat
    var dayOfMonth:Int
    var monthNumStr:String
    var yearNumStr:String

    @State var showSheet:Bool = false
    @State private var showPhotoView = false

    var body: some View {
        
        let dayNumStr = dayOfMonth < 10 ? "0\(dayOfMonth)" : "\(dayOfMonth)"
        
        if album.images.count > 0 && album.timesDict["\(yearNumStr)-\(monthNumStr)-\(dayNumStr)"] != nil {
            
            let imageList: [Image] = album.photosDict["\(yearNumStr)-\(monthNumStr)-\(dayNumStr)"]!
            
            Button {
                showSheet.toggle()
            } label: {
                ZStack {
                    imageList[0]
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: height)
                        .cornerRadius(4)
                    HStack {
                        Text(dayOfMonth.description)
                            .foregroundColor(.white)
                            .font(.custom("Brother1816-Meduim", size: 24))
                            .shadow(color: .black, radius: 2, x:0.5, y:0.5)
                    }
//                    .background(Color("Accent").opacity(0.7))
                    .cornerRadius(4)
                }
            }
            .frame(width: 40, height: height)
            .sheet(isPresented: $showSheet) {
                BottomSheetView(date:"\(yearNumStr)-\(monthNumStr)-\(dayNumStr)", showPhotoView: $showPhotoView, imageList: imageList).presentationDetents([.fraction(0.60)])
            }
            .background(NavigationLink(destination: PhotoView(imageList:imageList, dateString:"\(yearNumStr)-\(monthNumStr)-\(dayNumStr)", timeList: album.timesDict["\(yearNumStr)-\(monthNumStr)-\(dayNumStr)"]!, showPhotoView: $showPhotoView), isActive: $showPhotoView) {
                EmptyView()
                
            })
            .onChange(of: showPhotoView) { newValue in
            }
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color("Background"))
                    .frame(height: height)
                Text(dayOfMonth.description)
                    .foregroundColor(.primary)
                    .font(.custom("Brother 1816", size: 20))
            }
        }
    }
}

struct CalendarCell_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}

func getIndex(index: Int) {
    print(String(index))
}
