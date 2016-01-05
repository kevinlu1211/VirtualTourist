//
//  Flickr.swift
//  VirtualTourist
//
//  Created by Kevin Lu on 24/12/2015.
//  Copyright © 2015 Kevin Lu. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class FlickrClient : NSObject {
    
    // MARK: - API Constants
    let BASE_URL = "https://api.flickr.com/services/rest/"
    let METHOD_NAME = "flickr.photos.search"
    let API_KEY = "fff5a8d23614bcae2145ea8f781be8ca"
    let DATA_FORMAT = "json"
    let EXTRAS = "url_m"
    let NO_JSON_CALLBACK = "1"
    let PHOTOS_PER_PAGE = "250"
    

    override init() {
        super.init()
    }
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
    func getFlickrImagesURL(hostViewController : PhotosViewController, completionHandler : (result: AnyObject!, success : Bool, errorString : String?) -> Void) {
        let urlString = getURLString(hostViewController.annotation!)
        print(urlString)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // Testing for connection error
            guard (error==nil) else {
                completionHandler(result:nil, success: false, errorString: "Error in connection")
                return
            }
            guard let data = data else {
                completionHandler(result:nil, success: false, errorString: "No data retrieved from server")
                return
            }
    
            
            // Try to convert the data into JSON format
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
            } catch {
                parsedResult = nil
                completionHandler(result:nil, success: false, errorString: "Couldn't convert data to JSON")
                return
            }
            
            // Check that the data we have got is good
            guard let stat = parsedResult["stat"] as? String where stat == "ok" else {
                completionHandler(result:nil, success: false, errorString: "Error in data retrieval")
                return
            }
            
            self.getURL(hostViewController, parsedResult: parsedResult as? NSDictionary) { (result, success, error) in
                if (success) {
                    completionHandler(result:result, success: true, errorString: nil)
                }
                else {
                    completionHandler(result:nil, success: false, errorString: error)
                }
            }
        }
        task.resume()

    }
    
    func getURL(hostViewController: PhotosViewController, parsedResult : NSDictionary?, completionHandler : (result : AnyObject!, success : Bool, errorString : String?) -> Void) {
        let maxNumberOfPhotos = 21
        if let parsedResult = parsedResult {
            let photosInPage = parsedResult["photos"]!["photo"]!!.count
            var photosInfo = [[String : AnyObject]]()
            
            // If less than 21 photos then get them all
            if photosInPage < maxNumberOfPhotos {
                for (var i = 0; i < photosInPage; i++) {
    
                    // Select the photo and get it's properties
                    let photoSelected = parsedResult["photos"]!["photo"]!![i]
                    photosInfo.append(photoSelected as! [String : AnyObject])
                            
                        
                }
                completionHandler(result: photosInfo, success: true, errorString: nil)
            }
            // If more than 21 then get 21 random photos
            else {
                for (var i = 0; i < maxNumberOfPhotos; i++) {
                    let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosInPage)))
                    let photoSelected = parsedResult["photos"]!["photo"]!![randomPhotoIndex]
                    photosInfo.append(photoSelected as! [String : AnyObject])
                    print(photoSelected)
                }
                completionHandler(result: photosInfo, success: true, errorString: nil)
            }
        }
    }
    
    func getImageData(imagePath : String, completionHandler : (imageData : NSData?, errorString : String?) -> Void){
        let imageURL = NSURL(string: imagePath)
        let request = NSURLRequest(URL: imageURL!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(imageData: nil, errorString: "There was an error")
                return
            }
            
            if let data = data {
                completionHandler(imageData: data, errorString: nil)
            }
                
            else {
                completionHandler(imageData: nil, errorString: "Couldn't retrieve data")
                return
            }
            
            
        }
        task.resume()
    }
    func getURLString(annotation : MKAnnotation) -> String {
        let latitude = Double(annotation.coordinate.latitude)
        let longitude = Double(annotation.coordinate.longitude)
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "format": DATA_FORMAT,
            "extras":EXTRAS,
            "nojsoncallback":NO_JSON_CALLBACK,
            "per_page":PHOTOS_PER_PAGE,
            "lat":latitude,
            "lon":longitude
        ]
        return BASE_URL + escapedParameters(methodArguments as! [String : AnyObject])
    }
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }

    struct Caches {
        static let imageCache = ImageCache()
    }
}