//
//  Pin.swift
//  VirtualTourist
//
//  Created by Kevin Lu on 21/12/2015.
//  Copyright © 2015 Kevin Lu. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class CustomAnnotation : NSManagedObject, MKAnnotation {
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude : NSNumber
    @NSManaged var title : String?
    @NSManaged var subtitle: String?
    @NSManaged var photos : [Photo]?
    
    var coordinate = CLLocationCoordinate2D()
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context : NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(coordinate : CLLocationCoordinate2D, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("CustomAnnotation", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.longitude = coordinate.longitude
        self.latitude = coordinate.latitude
        print(photos)
    }
    
//    var coordinate : CLLocationCoordinate2D  {
//        get {
//            let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(self.longitude), CLLocationDegrees(self.latitude))
//            return coordinate
//        }
//    }
    func setCoordinate() {
        self.coordinate.longitude = CLLocationDegrees(self.longitude)
        self.coordinate.latitude = CLLocationDegrees(self.latitude)
    }
}

