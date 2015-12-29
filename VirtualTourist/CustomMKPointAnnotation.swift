//
//  CustomMKPointAnnotation.swift
//  VirtualTourist
//
//  Created by Kevin Lu on 23/12/2015.
//  Copyright © 2015 Kevin Lu. All rights reserved.
//

import Foundation
import MapKit
import CoreData
class CustomMKPointAnnotation : MKPointAnnotation {
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context : NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(pointAnnotation : MKPointAnnotation, context : NSManagedObjectContext) {
        
    }
}