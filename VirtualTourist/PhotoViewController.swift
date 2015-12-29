//
//  PhotoViewController.swift
//  VirtualTourist
//
//  Created by Kevin Lu on 28/12/2015.
//  Copyright © 2015 Kevin Lu. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    @IBOutlet weak var photoView: UIImageView!
    var image = UIImage()
    
    var navigationBarHidden = false
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: "setNavigationBar")
        self.photoView.addGestureRecognizer(tapGesture)
        photoView.image = image
        // Do any additional setup after loading the view.
    }

    func setNavigationBar() {
        if navigationBarHidden {
            self.navigationController?.navigationBar.hidden = false
        }
        else {
            self.navigationController?.navigationBar.hidden = true
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
