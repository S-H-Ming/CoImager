//
//  ViewController.swift
//  Controller
//
//  Created by CGLab on 26/12/2017.
//  Copyright © 2017 Howard Chang. All rights reserved.
//

import UIKit
import Metal
import CoreImage
import CoreGraphics
import QuartzCore
//import CoreGraphics

class ViewController: UIViewController {

    @IBOutlet weak var lightOn: UIImageView!
    @IBOutlet weak var Origin: UIImageView!
    @IBOutlet weak var Gray: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func convertToGray(image:UIImage)->UIImage{
        let ciImage = CIImage(image: image)
        let light_on = CIImage(image: lightOn.image!)
        
        
        let filter = CIFilter(name: "CISubtractBlendMode")
 
        
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(light_on, forKey: kCIInputBackgroundImageKey)
        let output = UIImage(ciImage: (filter?.outputImage)!)
        
        return output
    }
    
    @IBOutlet weak var RunTime: UILabel!
    
    @IBAction func Convert(_ sender: UIButton) {
        let start = CACurrentMediaTime()
        Gray.image = convertToGray(image: Origin.image!)
        let end = CACurrentMediaTime()
        RunTime.text = "runtime=" + String(end-start)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    
    
    
}

