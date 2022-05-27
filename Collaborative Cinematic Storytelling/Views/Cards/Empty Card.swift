//
//  Empty Card.swift
//  Collaborative Cinematic Storytelling
//
//  Created by Hasan Tahir on 04/05/2022.
//

import SwiftUI

struct EmptyCard : View {
    
    var shouldShowPlus = false
    
    var didPressedAdd: (() -> Void)? = nil
    
    var body: some View {
        
        ZStack{
            
            RoundedRectangle(cornerRadius: 12, style: .circular)
                .strokeBorder(.gray)
                .foregroundColor(.clear)
                .background(Color.clear)
                .frame(width: cardWidth, height: cardHeight)
            
            
            if shouldShowPlus {
                Button {
                    didPressedAdd?()
                } label: {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 50, height: 50, alignment: .center)
                }
                .frame(width: 80, height: 50, alignment: .center)
            }
        }
    }
}
