//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Kevin Lu on 28/12/2015.
//  Copyright © 2015 Kevin Lu. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    var photoImageView : UIImageView!
    var activityIndicator : UIActivityIndicatorView!
    @nonobjc var isSelected = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Setup PhotoImageView
        self.photoImageView = UIImageView(frame: self.contentView.bounds)
        let placeHolderImage = UIImage(named: "placeHolderImage")
        photoImageView.image = placeHolderImage
        self.addSubview(photoImageView)
        
        // SetupActivityIndicator
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        self.activityIndicator.center = self.contentView.center
        self.addSubview(activityIndicator)
        self.bringSubviewToFront(activityIndicator)
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Setup PhotoImageView
        self.photoImageView = UIImageView(frame: self.contentView.bounds)
        let placeHolderImage = UIImage(named: "placeHolderImage")
        photoImageView.image = placeHolderImage
        self.addSubview(photoImageView)
        
        // SetupActivityIndicator
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        self.activityIndicator.center = self.contentView.center
        self.addSubview(activityIndicator)
        self.bringSubviewToFront(activityIndicator)

    }
}
