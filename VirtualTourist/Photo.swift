//
//  Photo.swift
//  VirtualTourist
//
//  Created by Kevin Lu on 24/12/2015.
//  Copyright © 2015 Kevin Lu. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Photo : NSManagedObject {
    
    @NSManaged var imagePath : String
    @NSManaged var photoID : String
    @NSManaged var customAnnotation : CustomAnnotation?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    init(dictionary : [String : AnyObject], context : NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.imagePath = dictionary["url_m"] as! String
        self.photoID = dictionary["id"] as! String
    }
    
    var photoImage : UIImage? {
        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier(photoID)
        }
        set {
            FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: photoID)
        }
    }
}