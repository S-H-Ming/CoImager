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
    /*
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
    */
}

