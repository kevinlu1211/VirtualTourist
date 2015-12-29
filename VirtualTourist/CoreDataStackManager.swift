//
//  CoreDataStackManager.swift
//  VirtualTourist
//
//  Created by Kevin Lu on 21/12/2015.
//  Copyright © 2015 Kevin Lu. All rights reserved.
//

import Foundation
import CoreData

private let SQLITE_FILE_NAME = "VirtualTourist.sqlite"

class CoreDataStackManager {
    // MARK: - Shared Instance
    
    class func sharedInstance() -> CoreDataStackManager {
        struct Singleton {
            static let instance = CoreDataStackManager()
        }
        return Singleton.instance
    }
    
    

    lazy var managedObjectContext : NSManagedObjectContext = {
        // Setting the coordinator for the ManagedObjectContext
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    lazy var persistentStoreCoordinator : NSPersistentStoreCoordinator? = {
        
        // Telling the PersistentStoreCoordinator the structure of the model
        let coordinator : NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        // Getting the URL for where the file should be stored
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(SQLITE_FILE_NAME)
        
//        print("sqlite path: \(url.path!)")
        
        // Attempting to create a persistent store at url.path
        
        var failureReason = "There was an error creating or loading the application's saved data."
        
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            var dict = [String : AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as! NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError)")
            print("")
            NSLog("Unresolved error \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectModel : NSManagedObjectModel =  {
        let modelURL = NSBundle.mainBundle().URLForResource("VirtualTourist", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var applicationDocumentsDirectory : NSURL = {
        // Getting the URL to the users documents
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
                print("Saved!")
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
}