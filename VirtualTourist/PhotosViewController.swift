//
//  PhotosViewController.swift
//  VirtualTourist
//
//  Created by Kevin Lu on 23/12/2015.
//  Copyright © 2015 Kevin Lu. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: - Constants
    let navigationBarFontSize : CGFloat = 17.0
    
    // MARK: - Variables
    var annotation : CustomAnnotation?
    var sharedContext : NSManagedObjectContext  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    var selecting = false
    var selectedIndexPaths = [NSIndexPath]()
    
    // MARK: - UI Variables
    var snapshotter : MKMapSnapshotter?
    var mapImageView : UIImageView?
    var collectionView : UICollectionView?
    var selectButton : UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var toolbarButton: UIBarButtonItem!
    
    // MARK: - Lifecycle
    override func viewWillAppear(animated: Bool) {
        print("in view will appear")
        super.viewWillAppear(animated)
        retrieveImageData()
        // If it is empty then load images
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()

        // Do any additional setup after loading the view.
    }
       override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Setup UI
    func retrieveImageData() {
        if (annotation?.photos)!.isEmpty {
            // Load photos
            print("downloading photos")
            FlickrClient.sharedInstance().getFlickrImagesURL(self) {(result, success, errorString) in
                dispatch_async(dispatch_get_main_queue()) {
                    if success {
                        print("loading photos")
                        
                        // Use the inverse relationship to save the data
                        if let photosDictionaries = result as! [[String : AnyObject]]? {
                            print(photosDictionaries)
                            _ = photosDictionaries.map() { (dictionary: [String : AnyObject]) -> Photo in
                                let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                                
                                photo.customAnnotation = self.annotation!
                                
                                return photo
                            }
                        }
                        print(self.annotation?.photos)
                        
                        
                        self.collectionView!.reloadData()
                        
                        CoreDataStackManager.sharedInstance().saveContext()
                        
                        
                    }
                    else {
                        self.showAlert("Error", message: errorString!, confirmButton: "OK")
                    }
                    
                }
            }
        }
    }
    func configureUI() {
        setupImageView()
        setupCollectionView()
        setupNavigationBar()
        setupToolbar()
    }
    

    func setupImageView() {
        // Creating Image View
        let navigationBarFrame = self.navigationController?.navigationBar.frame
        let imageViewFrame = CGRectMake(navigationBarFrame!.origin.x, navigationBarFrame!.maxY, self.view.frame.width, self.view.frame.height * 0.2)
        mapImageView = UIImageView(frame: imageViewFrame)
        self.view.addSubview(mapImageView!)
        
        // Snapping the shot
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        self.view.addSubview(activityIndicator)
        activityIndicator.center = (mapImageView?.center)!
        print(activityIndicator.center)
        activityIndicator.startAnimating()
        mapImageView!.bringSubviewToFront(activityIndicator)

        print("snapping the shot")
        if let snapshotter = snapshotter {
            snapshotter.startWithCompletionHandler() { snapshot, error in
                dispatch_async(dispatch_get_main_queue()) {
                    if snapshot != nil {
                        let mapImage = snapshot!.image
                        
                        // Creating the pin (but just need the image)
                        let pin = MKPinAnnotationView(annotation: nil, reuseIdentifier: "")
                        let pinImage = pin.image
                        
                        print("starting to draw")
                        // Start drawing
                        UIGraphicsBeginImageContextWithOptions(mapImage.size, true, mapImage.scale)
                        // Setting up to draw the pin
                        mapImage.drawAtPoint(CGPointMake(0, 0))
                        var pinPoint = snapshot!.pointForCoordinate(self.annotation!.coordinate)
                        
                        // Drawing the pin
                        pinPoint.x = mapImage.size.width/2
                        pinPoint.y = mapImage.size.height/2
                        pinImage?.drawAtPoint(pinPoint)
                        
                        // Finally get the image
                        
                        print("finished drawing and getting image")
                        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        
                        print("got image")
                        self.mapImageView!.image = finalImage
                        activityIndicator.stopAnimating()

                    }
                }
            }

        }
        
        
    }
    
    func setupCollectionView() {
        // Creating the collection view so that it is between the mapImage and the toolbar
        let space = 3.0 as CGFloat
        let collectionViewFrame = CGRectMake(mapImageView!.frame.origin.x, mapImageView!.frame.maxY + space, self.view.frame.width, self.view.frame.maxY - mapImageView!.frame.maxY - space)
        let flowLayout = UICollectionViewFlowLayout()
        
        let width = (self.view.frame.size.width - (2 * space))/space
        let height = (self.view.frame.size.height - (2 * space))/space
        
        // Set left and right margins
        flowLayout.minimumInteritemSpacing = space
        
        // Set top and bottom margins
        flowLayout.minimumLineSpacing = space
        
        if (width > height) {
            flowLayout.itemSize = CGSizeMake(height, height)
        } else {
            flowLayout.itemSize  = CGSizeMake(width, width)
        }
        
        collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: flowLayout)
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.registerClass(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "cellID")
        
        collectionView?.backgroundColor = UIColor.whiteColor()
        
        self.view.addSubview(collectionView!)
    }

    func setupNavigationBar() {
        selectButton = UIBarButtonItem(title: "Select", style: .Plain, target: self, action: "selectButtonAction")
        self.navigationItem.rightBarButtonItem = selectButton
    }
    
    func setupToolbar() {
        self.view.bringSubviewToFront(toolbar)
    }
    
    func selectButtonAction() {

        if selecting {
            selecting = false
            selectButton.title = "Select"
            toolbarButton.title = "Discover More Photos"
        }
        else {
            selecting = true
            selectButton.title = "Done"
            toolbarButton.title = "Remove Selected Photos"
        }
    }
    

    // MARK: - Reload Photos
    @IBAction func reloadCollectionView(sender: AnyObject) {
        var photosArray = annotation!.photos!
        if selecting {
            // Delete the photos from the photos array
            for path in selectedIndexPaths {
                print("selected path: \(path.row)")
                
                // Using inverse relationship to delete elements of array
                photosArray[path.row].customAnnotation = nil
                sharedContext.deleteObject(photosArray[path.row])
            }
            
            CoreDataStackManager.sharedInstance().saveContext()
            print(photosArray.count)
            
            collectionView?.performBatchUpdates({ () -> Void in
                self.collectionView?.deleteItemsAtIndexPaths(self.selectedIndexPaths)
                }, completion: nil)
            selectedIndexPaths.removeAll()
        }
        else {
            // If the user isn't removing photos then they must want to reload it
            
            // Delete elements of array
            for photo in photosArray {
                photo.customAnnotation = nil
                sharedContext.deleteObject(photo)
            }
            
            // Save it to CoreData
            CoreDataStackManager.sharedInstance().saveContext()
            
            // Retrieve new images
            retrieveImageData()
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(annotation?.photos!.count)
        return (annotation?.photos!.count)!
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cellID", forIndexPath: indexPath) as! PhotoCollectionViewCell
        let photo = annotation!.photos![indexPath.row]
        
        if selectedIndexPaths.contains(indexPath) {
            cell.alpha = 0.3
        }
        
        configureCell(cell, photo: photo)
        
        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCollectionViewCell
        if selecting && selectedCell.isSelected == false {
            selectedCell.alpha = 0.3
//            print("selecting this photo")
            selectedCell.isSelected = true
            selectedIndexPaths.append(indexPath)
        }
        else if selecting && selectedCell.isSelected == true {
            selectedCell.alpha = 1.0
//            print("unselecting this photo")
            selectedCell.isSelected = false
            selectedIndexPaths.removeObject(indexPath)
        }
        else {
            let photoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("photoViewController") as! PhotoViewController
            photoViewController.image = selectedCell.photoImageView.image!
            self.navigationController?.pushViewController(photoViewController, animated: true)
        }
    }
    func configureCell(cell : PhotoCollectionViewCell, photo : Photo) {
        // Get imagePath of image
        let imagePath = photo.imagePath
        
        // Set default image
        var photoImage = UIImage(named: "placeHolderImage")
        cell.photoImageView.image = photoImage
        
        // Start indicator
        cell.activityIndicator.startAnimating()
        
        // Check if the image is saved in Cache or Documents Directory
        if photo.photoImage != nil {
//            print("Got Image from storage")
            photoImage = photo.photoImage
            cell.photoImageView.image = photoImage
            cell.activityIndicator.stopAnimating()
            CoreDataStackManager.sharedInstance().saveContext()

        }
        else {
            // Retrieve image and set it
            FlickrClient.sharedInstance().getImageData(imagePath) { data, error in
                if let data = data {
                    dispatch_async(dispatch_get_main_queue()) {
//                        print("Got image from internet")
                        photoImage = UIImage(data: data)
                        cell.activityIndicator.stopAnimating()
                        cell.photoImageView.image = photoImage
                        photo.photoImage = photoImage
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue()) {
                        photoImage = UIImage(named: "placeHolderNoImage")
                        cell.activityIndicator.stopAnimating()
                        cell.photoImageView.image = photoImage
                    }
                }
            }
        }
    }
}
