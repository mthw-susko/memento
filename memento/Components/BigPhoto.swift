//
//  BigPhoto.swift
//  InfiniteScroll
//
//  Created by Matthew Susko on 2023-08-13.
//

import SwiftUI

struct BigPhoto: View {
    var image: Image = Image("test")
    var time: String = "12:12:12"
    
    var body: some View {
        ZStack(alignment:.topTrailing) {
            image
                .resizable()
                .scaledToFit()
            VStack(alignment: .trailing) {
                // time also has a location with it
                
//                    VStack(alignment: .trailing) {
//                        Text(time)
//                            .font(.title2)
//                            .foregroundColor(.white)
//                            .padding(.horizontal, 1)
//                            .shadow(color: .black, radius: 2, x:0.5, y:0.5)
//
//                    }
                if time.count > 8 {
                    let timeSplit = time.split(separator: " ")
                    VStack(alignment: .trailing) {
                        Text(String(describing: timeSplit[0]))
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 1)
                            .shadow(color: .black, radius: 2, x:0.5, y:0.5)
                        Text(String(describing: timeSplit[1]))
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 1)
                            .shadow(color: .black, radius: 2, x:0.5, y:0.5)

                    }

                } else {
                    Text(time)
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 1)
                        .shadow(color: .black, radius: 2, x:0.5, y:0.5)
                }
            }
            .cornerRadius(4)
            .padding()
        }
        .cornerRadius(4)
        .frame(width:350)
    }
}

struct BigPhoto_Previews: PreviewProvider {
    static var previews: some View {
        BigPhoto()
    }
}

extension Text {
    func getContrastText(backgroundColor: Color) -> some View {
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)
        UIColor(backgroundColor).getRed(&r, green: &g, blue: &b, alpha: &a)
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return  luminance < 0.6 ? self.foregroundColor(.white) : self.foregroundColor(.black)
    }
}
