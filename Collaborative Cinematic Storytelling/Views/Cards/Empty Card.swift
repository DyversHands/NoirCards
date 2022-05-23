//
//  Empty Card.swift
//  Collaborative Cinematic Storytelling
//
//  Created by Hasan Tahir on 04/05/2022.
//

import SwiftUI

struct EmptyCard : View{
    var body: some View{
        HStack{
            RoundedRectangle(cornerRadius: 12, style: .circular)
                .strokeBorder(.gray)
                .foregroundColor(.clear)
                .background(Color.clear)
                .frame(width: cardWidth - 10, height: cardHeight)
        }
    }
}
