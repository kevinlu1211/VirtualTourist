//
//  ImageCache.swift
//  VirtualTourist
//
//  Created by Kevin Lu on 28/12/2015.
//  Copyright © 2015 Kevin Lu. All rights reserved.
//

import UIKit

class ImageCache {
    
    private var inMemoryCache = NSCache()
    
    // MARK: - Retrieving images
    
    func imageWithIdentifier(identifier : String?) -> UIImage? {
        if identifier == nil || identifier! == "" {
            return nil
        }
        let path = pathForIdentifer(identifier!)
        
//        print("Retrieving image at path: \(path)")
        
        if let image = inMemoryCache.objectForKey(path) as? UIImage {
//            print("In Cache")
            return image
        }
        
        if let data = NSData(contentsOfFile: path) {
//            print("In Documents Directory")
            return UIImage(data : data)
        }
        
        print("Found nothing")
        return nil
    }
    
    func storeImage(image: UIImage?,  withIdentifier identifer : String) {
        let path = pathForIdentifer(identifer)
        
        // If there is no image then remove the images from the cache
        if image == nil {
            inMemoryCache.removeObjectForKey(path)
            
            do {
                try NSFileManager.defaultManager().removeItemAtPath(path)
            }
            catch _ {}
            
            return
        }
        
//        print("Storing image at path: \(path)")
        
        // If not nil then set the image in memory
        inMemoryCache.setObject(image!, forKey: path)
        
        // And also in documents directory
        let data = UIImagePNGRepresentation(image!)! // need to convert to PNG as this is only format that images can be saved
        data.writeToFile(path, atomically: true)
        
    }
    
    func pathForIdentifer(identifier: String) -> String {
        let documentsDirectoryURL : NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        
        return fullURL.path!
    }
}