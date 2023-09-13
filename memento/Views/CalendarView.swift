//
//  CalendarView.swift
//  InfiniteScroll
//
//  Created by Matthew Susko on 2023-08-12.
//

import SwiftUI

func generateMonths (startYear: Int, startMonth: Int) -> [MonthModel] {
    
    let endMonth = Calendar.current.component(.month, from: Date())
    let endYear = Calendar.current.component(.year, from: Date())
    var monthList: [MonthModel] = []
    
    if (endYear-startYear != 0) {
        for month in startMonth...12 {
            let monthStr = Calendar.current.monthSymbols[month-1] // April
            let monthNumStr = month < 10 ? "0\(month)" : "\(month)"
            
            monthList.append(MonthModel(id: UUID().uuidString, month: monthStr, monthOfTheYear: month, year: startYear, yearStr:String(startYear), monthNumStr: monthNumStr))
        }
        
        if (endYear-startYear > 1) {
            for year in 1...(endYear-(startYear+1)) {
                for month in 1...12 {
                    let monthStr = Calendar.current.monthSymbols[month-1] // April
                    let monthNumStr = month < 10 ? "0\(month)" : "\(month)"
                    monthList.append(MonthModel(id: UUID().uuidString, month: monthStr, monthOfTheYear: month, year: startYear+year, yearStr:String(startYear+year), monthNumStr: monthNumStr))
                }
            }
        }
            
        for month in 1...endMonth {
            let monthStr = Calendar.current.monthSymbols[month-1] // April
            let monthNumStr = month < 10 ? "0\(month)" : "\(month)"
            monthList.append(MonthModel(id: UUID().uuidString, month: monthStr, monthOfTheYear: month, year: endYear, yearStr:String(endYear), monthNumStr: monthNumStr))
        }
    } else {
        for month in startMonth...endMonth {
            let monthStr = Calendar.current.monthSymbols[month-1] // April
            let monthNumStr = month < 10 ? "0\(month)" : "\(month)"
            monthList.append(MonthModel(id: UUID().uuidString, month: monthStr, monthOfTheYear: month, year: endYear, yearStr:String(endYear), monthNumStr: monthNumStr))
        }
    }
    
    
    return monthList.reversed()
}


struct CalendarView: View {

    @StateObject var album: PhotoManager = PhotoManager()
    @State var todayDate = Date()
    @State var startDate = Calendar.current.date(from: DateComponents(year: 2023, month:7, day:1))!
    
    @State var months = generateMonths(startYear: 2023, startMonth: 1)
    
    @Environment(\.presentationMode) var mode

    private var daysOfTheWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private var columns = [
        GridItem.init(.flexible(), alignment: .center),
        GridItem.init(.flexible(), alignment: .center),
        GridItem.init(.flexible(), alignment: .center),
        GridItem.init(.flexible(), alignment: .center),
        GridItem.init(.flexible(), alignment: .center),
        GridItem.init(.flexible(), alignment: .center),
        GridItem.init(.flexible(), alignment: .center)
    ]

    var body: some View {
        NavigationStack {
                if album.hasPhotoAccess {
                    if !album.gettingImages {
                        ScrollView {
                            LazyVStack {
                                ForEach(months) { month in
                                        LazyVGrid(columns: columns, alignment: .center, pinnedViews: .sectionHeaders) {
                                            
                                            ForEach(1..<month.spacesBeforeFirst) { _ in
                                                Text("")
                                            }
                                            
                                            // Days in a month
                                            ForEach(1..<month.amountOfDays + 1) { i in
                                                
                                                CalendarCell(beforeImageURL: "", afterImageURL: "", date: "", height: UIScreen.main.bounds.width/6.5, dayOfMonth: i, monthNumStr: month.monthNumStr, yearNumStr: month.yearStr).environmentObject(album)
                                                
                                            }
                                            
                                        }
                                            .padding(.horizontal)
                                            .flippedUpsideDown()
                                        
                                        HStack(spacing: 0) {
                                            ForEach(daysOfTheWeek, id: \.self) { d in
                                                Text(d)
                                                    .font(.custom("Brother1816-Medium", size: 16))
                                                    .padding(.horizontal, 13)
                                                    .padding(.vertical, 5)
                                            }
                                        }
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(.primary)
                                        .flippedUpsideDown()
                                        HStack {
                                            Text("\(month.month) \(month.yearStr)")
                                                .font(.custom("Brother1816-BoldItalic", size: 20))
                                                .frame(alignment: .leading)
                                                .foregroundColor(.white)
                                                .padding(.all, 5)
                                                .background(Color("Accent"))
                                                .cornerRadius(4)
                                                .id(month.id)
                                                Spacer()
                                        }.padding(.leading, 10).flippedUpsideDown()

                                        
                                }
                            }
                        }
                        .toolbar {
                            ToolbarItemGroup(placement: .navigationBarLeading) {
                                HStack(spacing:0) {
                                    Text("memento")
                                        .font(.custom("Brother1816-BoldItalic", size: 24))
                                    Text(".")
                                        .font(.custom("Brother1816-BoldItalic", size: 24))
                                        .foregroundColor(Color("Accent"))
                                }.onTapGesture {
                                    album.gettingImages = true
                                    album.getPhotos()
                                }
                            }
                        }
                        .flippedUpsideDown()
                    .background(Color("Background"))
                    } else {
                        VStack {
                            Text("Loading Photos...")
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .toolbar {
                                    ToolbarItemGroup(placement: .navigationBarLeading) {
                                        HStack(spacing:0) {
                                            Text("memento")
                                                .font(.custom("Brother1816-BoldItalic", size: 24))
                                            Text(".")
                                                .font(.custom("Brother1816-BoldItalic", size: 24))
                                                .foregroundColor(Color("Accent"))
                                        }
                                    }
                                }
                        }
                    }
                } else {
                    ScrollView {
                        Text("please allow photo acces for app to function correctly")
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarLeading) {
                            HStack(spacing:0) {
                                Text("memento")
                                    .font(.custom("Brother1816-BoldItalic", size: 24))
                                Text(".")
                                    .font(.custom("Brother1816-BoldItalic", size: 24))
                                    .foregroundColor(Color("Accent"))
                            }
                        }
                    }
                }
            }
            .onChange(of: album.times) { times in
                if times.count > 0 {
                    let lastDateSplit = times[0].split(separator:"-")
                    let lastYear = Int(String(describing: lastDateSplit[0]))
                    let lastMonth = Int(String(describing: lastDateSplit[1]))
                    print(times)
                    months = []
                    months = generateMonths(startYear: lastYear!, startMonth: lastMonth!)
                }
            }
        }
    }

struct CalendarView_Previews: PreviewProvider { static var previews: some View { CalendarView() } }

struct FlippedUpsideDown: ViewModifier {
   func body(content: Content) -> some View {
    content
      .rotationEffect(.degrees(180))
      .scaleEffect(x: -1, y: 1, anchor: .center)
   }
}
extension View{
   func flippedUpsideDown() -> some View{
     self.modifier(FlippedUpsideDown())
   }
}
