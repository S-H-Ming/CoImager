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
    
    let imageSize:CGFloat = 300;
    
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        image.draw(in: CGRect(x:0,y: 0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
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
    
    func performRectangleDetection(image: UIKit.CIImage) -> UIKit.CIImage? {
        var resultImage: UIKit.CIImage?
        let detector:CIDetector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])!
        // Get the detections
        let features = detector.features(in: image)
        for feature in features as! [CIRectangleFeature] {
            resultImage = self.drawHighlightOverlayForPoints(
                image: image,
                topLeft: feature.topLeft,
                topRight: feature.topRight,
                bottomLeft: feature.bottomLeft,
                bottomRight: feature.bottomRight)
        }
        return resultImage
    }
    
    func drawHighlightOverlayForPoints(image: UIKit.CIImage, topLeft: CGPoint, topRight: CGPoint,
                                       bottomLeft: CGPoint, bottomRight: CGPoint) -> UIKit.CIImage {
        
        var overlay = UIKit.CIImage(color: CIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.45))
        overlay = overlay.cropped(to: image.extent)
        overlay = overlay.applyingFilter("CIPerspectiveTransformWithExtent",
                                                parameters: [
                                                    "inputExtent": CIVector(cgRect: image.extent),
                                                    "inputTopLeft": CIVector(cgPoint: topLeft),
                                                    "inputTopRight": CIVector(cgPoint: topRight),
                                                    "inputBottomLeft": CIVector(cgPoint: bottomLeft),
                                                    "inputBottomRight": CIVector(cgPoint: bottomRight)
            ])
        return overlay.composited(over: image)
    }
    
    @IBAction func Process(_ sender: UIButton) {
        let start = CACurrentMediaTime()
        
        //Decrease the of resolution of the input images
        LightOn.image =  resizeImage(image: LightOn.image!, newWidth: imageSize)
        LightOff.image = resizeImage(image: LightOff.image!, newWidth: imageSize)

        //Convert to grayscale then do background subtraction
        BackgroundSubtraction()
        
        //find screens in the background subtraction image
        var rectDetect = CIImage(image: Result.image!)
        if(rectDetect == nil){print("nil\n")}
        else {print("oK\n")}
        var temp = performRectangleDetection(image: rectDetect!)
        if(temp == nil){print("nil\n")}
        else {print("oK\n")}
        //Result.image = UIImage(ciImage: temp!)

        let end = CACurrentMediaTime()
        self.Runtime.text = "runtime=" + String(end-start)
    }
  
}
//back no return .
