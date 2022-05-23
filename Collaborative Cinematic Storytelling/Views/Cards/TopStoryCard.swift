//
//  TopStoryCard.swift
//  Collaborative Cinematic Storytelling
//
//  Created by Hasan Tahir on 04/05/2022.
//

import SwiftUI
import UIKit

struct TopStoryCard : View{
    
    @ObservedObject var viewModel: StoryViewModel
    
    var image : UIImage
    
    var body: some View {
        
        HStack{
            // Added Button Just to highlight the card when ever tapped to show user this card is tappable or draggable
            Button {
                print("TopStoryCard Pressed :/")
            } label: {
                Image(uiImage: image)
                    .resizable()
                    .cornerRadius(12)
                    .frame(width: cardWidth - 10, height: cardHeight)
            }
        }
        .contextMenu {
            Button {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
                    withAnimation {
                        viewModel.stackImages.removeAll(where: {$0.image == self.image})
                    }
                }
            } label: {
                Text("Discard Image")
            }
        }
    }
}
