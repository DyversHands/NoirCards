//
//  ImageModel.swift
//  Collaborative Cinematic Storytelling
//
//  Created by Hasan Tahir on 04/05/2022.
//

import Foundation
import UIKit

struct StoryModel : Hashable{
    var id : String = UUID().uuidString
    var imageName : String
    var image : UIImage {
        get{
            return UIImage(named: imageName)!
        }
    }
    var frame : CGRect = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
    var text : String = ""
    var isZoomed = false {
        didSet {
            isCardZoomed = isZoomed
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(imageName)
    }
}
