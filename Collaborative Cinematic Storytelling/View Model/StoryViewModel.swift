//
//  StoryViewModel.swift
//  Collaborative Cinematic Storytelling
//
//  Created by Hasan Tahir on 04/05/2022.
//

import Foundation
import UIKit
import SwiftUI

public class StoryViewModel: ObservableObject {
    
    private var images = [StoryModel]()
    @Published var stackImages = [StoryModel](){
        didSet{
            print("did Set stackImages \(stackImages.count)")
            updateStackImages()
            print("update stackImages \(stackImages.count)")
        }
    }
    @Published var droppedImages = [StoryModel]() {
        didSet{
            print("droppedImages")
            updateBoardImages()
        }
    }
    
    
    init() {
        
        droppedImages = CoreDataManager.shared.fetchMediaFromCoreData(placement: Placement.dropped.rawValue)
        stackImages = CoreDataManager.shared.fetchMediaFromCoreData(placement: Placement.stack.rawValue)
        print("init stackImages \(stackImages.count)")
        images.removeAll()
        for i in 1...272{
            let imgNum = i < 10 ? "00\(i)" : i < 100 ?  "0\(i)" : "\(i)"
            images.append(StoryModel(imageName: "Noir Sample Cards.\(imgNum)", location: .zero))
        }
        
    }
    
    func pickRandomImage(){
        
        if stackImages.count > 6{
            stackImages.removeFirst()
        }
        
        if let img = images.randomElement(){
            stackImages.append(img)
        }
        print(stackImages)
    }
    
    func updateStackImages(){
        CoreDataManager.shared.deleteAllData(placement: Placement.stack.rawValue)
        stackImages.forEach { model in
            CoreDataManager.shared.addMediaToCoreData(model: model, placement: Placement.stack.rawValue)
        }
    }
    
    func updateBoardImages(){
        CoreDataManager.shared.deleteAllData(placement: Placement.dropped.rawValue)
        droppedImages.forEach { model in
            CoreDataManager.shared.addMediaToCoreData(model: model, placement: Placement.dropped.rawValue)
        }
    }
}

enum Placement : String{
    case stack = "stack"
    case dropped = "dropped"
}
