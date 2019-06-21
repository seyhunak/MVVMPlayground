//
//  PhotoDetailViewController.swift
//  MVVMPlayground
//
//  Created by sakyurek on 11/10/2018.
//  Copyright © 2018 Seyhun Akyürek. All rights reserved.
//

import UIKit
import SDWebImage

class PhotoDetailViewController: UIViewController {

    var imageUrl: String?
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let imageUrl = imageUrl {
            imageView.sd_setImage(with: URL(string: imageUrl)) { (image, error, type, url) in
                print(url!)
                print(type)
                print(image!)

            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
