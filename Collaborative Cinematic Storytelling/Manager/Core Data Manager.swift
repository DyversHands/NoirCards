//
//  Core Data Manager.swift
//  PPLE
//
//  Created by Hasan on 08/07/2020.
//  Copyright © 2020 Hasan. All rights reserved.
//

import Foundation
//

import Foundation
import CoreData
import UIKit
import AVFoundation

class CoreDataManager{
    
    var context : NSManagedObjectContext!
    
    private static var _obj : CoreDataManager? = nil
    class var shared:CoreDataManager{
        get{
            if _obj == nil{
                _obj = CoreDataManager()
                _obj?.configureCoreData()
                
            }
            let lockQueue = DispatchQueue(label: "_obj")
            return lockQueue.sync{
                return _obj!
            }
        }
        
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Collaborative_Cinematic_Storytelling")
        
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    func configureCoreData(){
        
        context = self.persistentContainer.viewContext
    }
    
    // retrieving data to core data
    
    func addMediaToCoreData(model:StoryModel, placement : String){
        let entity = NSEntityDescription.entity(forEntityName: "StoryCardCD", in: context)
        let mediaData = NSManagedObject(entity: entity!, insertInto: context)
        mediaData.setValue(model.id, forKey: "id")
        mediaData.setValue(model.imageName, forKey: "imageName")
        mediaData.setValue(model.location.x, forKey: "x")
        mediaData.setValue(model.location.y, forKey: "y")
        mediaData.setValue(model.text, forKey: "text")
        mediaData.setValue(placement, forKey: "placement")
        
        do {
            try context.save()
            
        } catch {
            print("Failed saving")
        }
        
    }
    // retrieving data from core data
    func fetchMediaFromCoreData(placement : String) -> [StoryModel]{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StoryCardCD")
       fetchRequest.predicate = NSPredicate(format: "placement = %@",placement)
        let result = try? context.fetch(fetchRequest)
        var mediaArr = [StoryModel]()
        for data in result as! [NSManagedObject]{
            guard let id = data.value(forKey: "id") as? String else {continue}
            guard let name = data.value(forKey: "imageName") as? String else {continue}
            guard let text = data.value(forKey: "text") as? String else {continue}
            guard let x = data.value(forKey: "x") as? Double else {continue}
            guard let y = data.value(forKey: "y") as? Double else {continue}
            
            let model = StoryModel(id: id, imageName: name, location: CGPoint(x: x, y: y), text: text)
            mediaArr.append(model)
            
        }
        return mediaArr
        
    }
    
    
    func deleteFromCoreData(model : StoryModel) {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StoryCardCD")
        fetchRequest.predicate = NSPredicate(format: "id = %@", model.id)
        
        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            
        } catch {
            // Error Handling
        }
    }
    
    // delete data from core data
    func deleteAllData(placement : String) {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StoryCardCD")
        fetchRequest.predicate = NSPredicate(format: "placement = %@",placement)
        
        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            
        } catch {
            print("Failed Deleting")
            // Error Handling
        }
    }
    
}
