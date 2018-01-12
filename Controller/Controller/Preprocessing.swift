//
//  Preprocessing.swift
//  Controller
//
//  Created by CGLab on 11/01/2018.
//  Copyright © 2018 Howard Chang. All rights reserved.
//

import Foundation
import UIKit
import CoreImage


class Preprocessing: UIViewController{
    @IBOutlet weak var LightOff: UIImageView!
    @IBOutlet weak var LightOn: UIImageView!
    @IBOutlet weak var Result: UIImageView!
    
    @IBOutlet weak var Runtime: UILabel!
    
    func ConvertToGray( image: UIImage?)->CIImage?{
        let ciImage = CIImage(image: image!)
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(0.0, forKey: kCIInputSaturationKey)
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        let output = filter?.outputImage
        return output
    }
    
    func BackgroundSubtraction(){
        //let ciImage = CIImage(image: image)
        let gray_light_off = ConvertToGray(image: LightOff.image)
        let gray_light_on = ConvertToGray(image: LightOn.image)
        
        LightOff.image = UIImage(ciImage: gray_light_off!)
        LightOn.image = UIImage(ciImage: gray_light_on!)
        
        let filter = CIFilter(name: "CISubtractBlendMode")
        filter?.setValue(gray_light_off, forKey: kCIInputImageKey)
        filter?.setValue(gray_light_on, forKey: kCIInputBackgroundImageKey)
        let output = UIImage(ciImage: (filter?.outputImage)!)
        
        Result?.image = output
        
        
    }

    
    
    @IBAction func Process(_ sender: UIButton) {
        let start = CACurrentMediaTime()
        BackgroundSubtraction()
        let end = CACurrentMediaTime()
        Runtime.text = "runtime=" + String(end-start)
    }
    
    
    
    
    
}
