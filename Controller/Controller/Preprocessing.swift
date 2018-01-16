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
import Vision

class Preprocessing: UIViewController{
    @IBOutlet weak var LightOff: UIImageView!
    @IBOutlet weak var LightOn: UIImageView!
    @IBOutlet weak var Result: UIImageView!
    
    @IBOutlet weak var Runtime: UILabel!
    
    let imageSize:CGFloat = 300;
    var screenCenters = [CGPoint]()
    let screenSize = 10.0;//pixel
    
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
        
        let ciImgae = filter?.outputImage
        let context = CIContext.init()
        let ref = context.createCGImage(ciImgae!, from: (ciImgae?.extent)!)
        Result?.image = UIImage(cgImage: ref!)
    }
    
    func performRectangleDetection() {
        guard let image = Result.image else { print("No Image"); return }
        
        var count = 0//record the number of rectangles

        let request = VNDetectRectanglesRequest { (req,err)
            in
            
            if let err = err{
                print("Failed to detect faces:",err)
                return
            }
            
            req.results?.forEach({ (res) in
                print("res",res)
                
                count += 1
                guard let faceObservation = res as? VNRectangleObservation else { print("VNRectangleObservation failed"); return }
                
                
            print(faceObservation.topLeft,faceObservation.topRight,faceObservation.bottomLeft,faceObservation.bottomRight)
                let width = self.Result.frame.width * faceObservation.boundingBox.width
                let height = self.Result.frame.height * faceObservation.boundingBox.height
                
                let x = self.Result.frame.width * faceObservation.boundingBox.origin.x
                let y = self.Result.frame.height * (1 -  faceObservation.boundingBox.origin.y) - height
                
                let redView = UIView()
                redView.backgroundColor = .red
                redView.alpha = 0.4
                redView.frame = CGRect(x: x, y: y, width: width, height: height)
                self.Result.addSubview(redView)
                
                print(faceObservation.boundingBox)
                
            })
        }
  
        request.maximumObservations = 0
        //        request.minimumConfidence = 0.5
        //        request.minimumSize = 0.5

        guard let cgImage = image.cgImage else { print("CGImage faile"); return }
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do{
            try handler.perform([request])
        } catch let reqErr{
            print("Failed to perform request:",reqErr)
        }
        
        print(count)
    }

    
    
    
    
    @IBAction func Process(_ sender: UIButton) {
        let start = CACurrentMediaTime()
        
        //Decrease the of resolution of the input images
        LightOn.image =  resizeImage(image: LightOn.image!, newWidth: imageSize)
        LightOff.image = resizeImage(image: LightOff.image!, newWidth: imageSize)

        //Convert to grayscale then do background subtraction
        BackgroundSubtraction()
        
        //find screens in the background subtraction image
        performRectangleDetection()
        
        let end = CACurrentMediaTime()
        Runtime.text = String(end-start)
        
    }
  
}
//back no return .
