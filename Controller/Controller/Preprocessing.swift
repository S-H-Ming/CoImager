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
    
    let imageSize:CGFloat = 500;
    var screenCenters = [CGRect]()
    let screenSize:CGFloat = 10.0;//pixel
    let sequenceCode = [String]()
    
    
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
    
    func FilterWithSequenceCodes(range: CGRect, isScreen: inout [Bool]){
        var index = 0
        let center = CGPoint(x: (range.origin.x + range.width)/2 , y: (range.origin.y + range.height)/2)
        for screen in screenCenters{
            let screenCenter = CGPoint(x: (screen.origin.x + screen.width)/2 , y: (screen.origin.y + screen.height)/2)
            if( fabs(center.x - screenCenter.x) < screenSize &&
                fabs(center.y - screenCenter.y) < screenSize   ){
                isScreen[index] = true
                break
            }
            index += 1
        }
    }
    
    func DeleteNoiseScreen(isScreen: [Bool]){
        let number = isScreen.count
        var offset = 0
        for i in 0...number-1{
            if( isScreen[i-offset] == false){
                screenCenters.remove(at: i-offset)
            }
            offset += 1
        }
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
            
            var isScreen = Array.init(repeating: false, count: self.screenCenters.count)
            req.results?.forEach({ (res) in
                print("res",res)
                
                count += 1
                guard let RectObservation = res as? VNRectangleObservation else { print("VNRectangleObservation failed"); return }
                
                if(count == 0){//first frame
                    self.screenCenters.append(RectObservation.boundingBox)
                }
                else{
                    self.FilterWithSequenceCodes(range: RectObservation.boundingBox, isScreen: &isScreen)
                }
                print("bounding ",RectObservation.boundingBox)
                //Highlight the rectangle
                print( RectObservation.topLeft,RectObservation.topRight,RectObservation.bottomLeft,RectObservation.bottomRight)
                let width = self.Result.frame.width * RectObservation.boundingBox.width
                let height = self.Result.frame.height * RectObservation.boundingBox.height
                
                let x = self.Result.frame.width * RectObservation.boundingBox.origin.x
                let y = self.Result.frame.height * (1 -  RectObservation.boundingBox.origin.y) - height
                
                let redView = UIView()
                redView.backgroundColor = .red
                redView.alpha = 0.4
                redView.frame = CGRect(x: x, y: y, width: width, height: height)
                self.Result.addSubview(redView)
                
            })
            DeleteNoiseScreen(isScreen)
        }
        
        request.maximumObservations = 0
        //        request.minimumConfidence = 0.5
        request.minimumSize = 0.05

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

