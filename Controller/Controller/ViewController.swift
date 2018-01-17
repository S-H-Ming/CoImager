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
import Vision

class ViewController: UIViewController {
    
    // ============= Default System Function =============
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ============= Image Preprocessing =============
    
    @IBOutlet weak var LightOff: UIImageView!
    @IBOutlet weak var LightOn: UIImageView!
    @IBOutlet weak var Result: UIImageView!
    @IBOutlet weak var Runtime: UILabel!
    
    let prep = Preprocessing()  // declare a Preprocessing Controller
    
    @IBAction func Process(_ sender: Any) {
        let start = CACurrentMediaTime()
        
        //Decrease the of resolution of the input images
        LightOn.image =  prep.resizeImage(image: LightOn.image!, newWidth: prep.imageSize)
        LightOff.image = prep.resizeImage(image: LightOff.image!, newWidth: prep.imageSize)
        
        //Convert to grayscale then do background subtraction
        BackgroundSubtraction()
        
        //find screens in the background subtraction image
        performRectangleDetection()
        
        let end = CACurrentMediaTime()
        Runtime.text = String(end-start)
    }
    
    func BackgroundSubtraction(){
        //let ciImage = CIImage(image: image)
        let gray_light_off = prep.ConvertToGray(image: LightOff.image)
        let gray_light_on = prep.ConvertToGray(image: LightOn.image)
        
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
            
            var isScreen = Array.init(repeating: false, count: self.prep.screenCenters.count)
            req.results?.forEach({ (res) in
                print("res",res)
                
                count += 1
                guard let RectObservation = res as? VNRectangleObservation else { print("VNRectangleObservation failed"); return }
                
                if(count == 0){//first frame
                    self.prep.screenCenters.append(RectObservation.boundingBox)
                }
                else{
                    self.prep.FilterWithSequenceCodes(range: RectObservation.boundingBox, isScreen: &isScreen)
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
            //self.DeleteNoiseScreen(isScreen: isScreen)
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

    
    // ============= Server Connecting =============
    
    @IBOutlet weak var clientNumLabel: UILabel!
    
    var searchResults: [String] = []
    let connect = ConnectController()

    @IBAction func Connect(_ sender: Any) {
        /*
        let input = "getCNum=TRUE"
        let phpindex = "getClientNum"
        
        connect.getSearchResults(inputData: input, phpindex: phpindex) { results, errorMessage in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if let results = results {
                self.searchResults = results
                self.clientNumLabel.text =
                    "client num = " + String(self.searchResults.count)
                print(results)
            }
            if !errorMessage.isEmpty { print("Search error: " + errorMessage) }
        }
        */
        self.Blink()
    }
    
    func Blink(){
        
        let input = ""
        let start = "startBlink"
        let end = "endBlink"
        
        connect.getSearchResults(inputData: input, phpindex: start) {_,_ in
            print("Start BLINKING!!")
        }
        
        let time: TimeInterval = 4.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
            self.connect.getSearchResults(inputData: input, phpindex: end) {_,_ in
                print("End BLINKING!!")
            }
        }
    }
    
}

