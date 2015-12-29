//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Kevin Lu on 21/12/2015.
//  Copyright © 2015 Kevin Lu. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {

    // MARK: - Constants
    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
    let navigationBarFontSize : CGFloat = 17.0
    let transparentBlack : UIColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.5)
    // Delete Label View
    let deletePinLabelFontSize : CGFloat = 17.0
    let deletePinLabelHeight : CGFloat = 20.0
    
    // MARK: - UI Variables
    @IBOutlet weak var mapView: MKMapView!
    var deletePinView : UIView?
    var deletePinLabel : UILabel?
    
    // MARK: - Instance Variables
    lazy var sharedContext : NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    var annotations = [CustomAnnotation]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureUI()
        configureMapView()
        populateAnnotations()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func configureUI() {
        
        // Setting up the title
        let textAttributes = [
            NSFontAttributeName : UIFont(name: "Roboto-Regular", size: navigationBarFontSize)!,
            NSForegroundColorAttributeName : UIColor.whiteColor()
        ]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        // Setting up edit button
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.editButtonItem().setTitleTextAttributes(textAttributes, forState: UIControlState.Normal)
        
        //Setting up the buttons and background for Navigation Controller
        UIBarButtonItem.appearance().setTitleTextAttributes(textAttributes, forState: UIControlState.Normal)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackOpaque
        self.navigationController?.navigationBar.translucent = true
        
        // Creating delete pin view
        createDeletePinView()
        
        // Creating delete pin label
        createDeletePinLabel()
    }
    
    func createDeletePinView() {
        let deletePinViewFrame = CGRectMake(self.view.frame.origin.x, self.view.frame.maxY, self.view.frame.width, 0.1 * self.view.frame.maxY)
        deletePinView = UIView(frame: deletePinViewFrame)
        if let deletePinView = deletePinView {
            deletePinView.backgroundColor = UIColor.redColor()
            deletePinView.hidden = true
            self.view.addSubview(deletePinView)
            
        }
        
    }
    
    func createDeletePinLabel () {
        if let deletePinView = deletePinView {
            let labelFrame = CGRectMake(0, 0, deletePinView.frame.width, deletePinLabelHeight)
            deletePinLabel = UILabel(frame: labelFrame)
            
            // Center the view
            deletePinLabel?.center = CGPointMake(deletePinView.frame.size.width/2, deletePinView.frame.size
            .height/2)
            
            deletePinView.addSubview(deletePinLabel!)
            self.view.bringSubviewToFront(deletePinLabel!)
        }
        configureDeletePinLabel()
    }
    
    func configureDeletePinLabel() {
        deletePinLabel!.font = UIFont(name: "Roboto-Medium", size: deletePinLabelFontSize)
        deletePinLabel!.textColor = UIColor.whiteColor()
        deletePinLabel!.text = "Tap Pins to Delete"
        deletePinLabel!.textAlignment = NSTextAlignment.Center
        printLine("deletePinConfigured")
        
    }

    // MARK: - Edit Button
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            printLine("editing")
            deletePinView!.hidden = false
            moveDeletePinView()
            print(deletePinLabel!.frame)
            print(deletePinView!.frame)
            // move the delete pin VC up
        }
        else {
            printLine("not editing")
            deletePinView!.hidden = true
            moveDeletePinView()
            // move the delete pin VC down
        }
    }
    
    
    // MARK: - Edit Button Helpers
    
    func moveDeletePinView() {
        if editing {
            self.view.frame.origin.y -= deletePinView!.frame.height
        }
        else {
            self.view.frame.origin.y += deletePinView!.frame.height
        }
    }
   
    // MARK: - NSKeyedArchiver
    // Getting filePath for the NSKeyedArchiver to save the user's last moved to location
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        return url.URLByAppendingPathComponent("mapRegionArchive").path!
    }
    
    func saveMapRegion() {
        
        // Place the "center" and "span" of the map into a dictionary
        // The "span" is the width and height of the map in degrees.
        // It represents the zoom level of the map.
        
        let dictionary = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
        
        // Archive the dictionary into the filePath
        NSKeyedArchiver.archiveRootObject(dictionary, toFile: filePath)

    }
    
    func restoreMapRegion(animated: Bool) {
        
        // if we can unarchive a dictionary, we will use it to set the map back to its
        // previous center and span
        if let regionDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String : AnyObject] {
            
            let longitude = regionDictionary["longitude"] as! CLLocationDegrees
            let latitude = regionDictionary["latitude"] as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let longitudeDelta = regionDictionary["latitudeDelta"] as! CLLocationDegrees
            let latitudeDelta = regionDictionary["longitudeDelta"] as! CLLocationDegrees
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            let savedRegion = MKCoordinateRegion(center: center, span: span)
            
            print("lat: \(latitude), lon: \(longitude), latD: \(latitudeDelta), lonD: \(longitudeDelta)")
            
            mapView.setRegion(savedRegion, animated: animated)
            print(mapView.region.span.latitudeDelta)
        }
    }
   
    // MARK: - Map View Actions
    func configureMapView() {
        mapView.delegate = self
        restoreMapRegion(false)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPressRecognizer.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressRecognizer)
    }
    
    func handleLongPress(gestureRecognizer : UIGestureRecognizer) {
        if gestureRecognizer.state != UIGestureRecognizerState.Began {
            return
        }
        let touchPoint : CGPoint = gestureRecognizer.locationInView(mapView)
        let touchMapCoordinates : CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        let annotationToBeAdded = CustomAnnotation(coordinate: touchMapCoordinates, context: sharedContext)
        
        // Add the pin to CoreData
        CoreDataStackManager.sharedInstance().saveContext()
        
        // Add the pin to mapView
        annotationToBeAdded.setCoordinate()
        mapView.addAnnotation(annotationToBeAdded)
    }
    
    func fetchAllPins() -> [CustomAnnotation] {
        // Create fetch request
        let fetchRequest = NSFetchRequest(entityName: "CustomAnnotation")
        do {
            let customAnnotations = try sharedContext.executeFetchRequest(fetchRequest) as! [CustomAnnotation]
            for annotation in customAnnotations {
                annotation.setCoordinate()
            }
            return customAnnotations
            
        } catch {
            return [CustomAnnotation]()
        }
    }
    
    func populateAnnotations() {
        // Get all the coordinates pins that were previously saved
        annotations = fetchAllPins()
        mapView.addAnnotations(annotations)
        
    }
    
    func removeAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.animatesDrop = true
            pinView!.pinTintColor = UIColor.redColor()
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let customAnnotation = view.annotation as! CustomAnnotation
        print("selected")
        if editing {
            // then delete from mapView and CoreData
            mapView.removeAnnotation(customAnnotation)
            sharedContext.deleteObject(customAnnotation)
            CoreDataStackManager.sharedInstance().saveContext()
        }
        else {
            // segue into new VC
            let photosViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PhotosViewController") as! PhotosViewController
            dispatch_async(dispatch_get_main_queue()) {
                self.setupPhotosViewController(photosViewController, annotation: customAnnotation)
                self.navigationController?.pushViewController(photosViewController, animated: true)
                mapView.deselectAnnotation(customAnnotation, animated: true)
            }
        }
    }

    func setupPhotosViewController(destinationViewController : PhotosViewController, annotation: CustomAnnotation) {
        
        // Create a new map view for the screen shot but with default scaling
        let screenshotMapView = mapView
        let mapCenter = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        let mapSpan = MKCoordinateSpan(latitudeDelta: 0.1 , longitudeDelta: 0.1)
        let screenshotRegion = MKCoordinateRegion(center: mapCenter, span: mapSpan)
        screenshotMapView.setRegion(screenshotRegion, animated: false)
        
        // Creating the snapshot
        let options = MKMapSnapshotOptions()
        options.region = screenshotMapView.region
        options.scale = UIScreen.mainScreen().scale
        options.size = CGSizeMake(self.view.frame.width, self.view.frame.height * 0.2)
        let snapshotter = MKMapSnapshotter(options: options)
        
        destinationViewController.snapshotter = snapshotter
        destinationViewController.annotation = annotation
        print("finished setting up the snapshot")
        
    }
    
    // MARK: - Convenience print
    func printLine(string: AnyObject) {
        if appDel.showComments {
            print(string)
        }
    }
}

extension MapViewController {
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
    }
}

