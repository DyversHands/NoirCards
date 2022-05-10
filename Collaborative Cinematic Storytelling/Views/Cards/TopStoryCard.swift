//
//  TopStoryCard.swift
//  Collaborative Cinematic Storytelling
//
//  Created by Hasan Tahir on 04/05/2022.
//

import SwiftUI
import UIKit

struct TopStoryCard : View{
    var image : UIImage
    var body: some View{
        HStack{
            Image(uiImage: image)
                .resizable()
                .cornerRadius(12)
                .frame(width: cardWidth, height: cardHeight)
        }
    }
    
}
