//
//  ViewController.swift
//  Down-Scaling-Image
//
//  Created by Xiaodan Wang on 7/2/18.
//  Copyright © 2018 Xiaodan Wang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var image = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Usage
    func downScaleImage() {
        // size you want
        let desiredSize = CGSize(width: 100.0, height: 100.0)
        
        var newImage: UIImage?
        
        newImage = image.resizeUI(size: desiredSize)
        newImage = image.resizeCG(size: desiredSize)
        newImage = image.resizeIO(size: desiredSize)
        newImage = image.resizeCI(size: desiredSize)
        newImage = image.resizeVI(size: desiredSize)
    }

}

