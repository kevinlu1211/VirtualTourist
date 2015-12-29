//
//  ArrayExtension.swift
//  VirtualTourist
//
//  Created by Kevin Lu on 29/12/2015.
//  Copyright © 2015 Kevin Lu. All rights reserved.
//

import Foundation

extension RangeReplaceableCollectionType where Generator.Element : Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(object : Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}
