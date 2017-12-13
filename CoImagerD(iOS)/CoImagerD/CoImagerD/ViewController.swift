//
//  ViewController.swift
//  CoImagerD
//
//  Created by CGLab on 2017/12/12.
//  Copyright © 2017年 Ming. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var timer = Timer()
    var isTimerRunning = false
    
    var fre: Int!
    @IBOutlet weak var fre_lbl: UITextField!
    @IBAction func slider(_ sender: UISlider) {
        fre = Int(sender.value)
        fre_lbl.text = String(fre)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fre = 60
    }
    
    @IBAction func FlashLight(_ sender: Any) {
        runTimer()
    }
    
    @IBAction func stopFlashLight(_ sender: Any) {
        timer.invalidate()
        if let device = AVCaptureDevice.default(for: AVMediaType.video), device.hasTorch{
            do{
                try device.lockForConfiguration()
                device.torchMode = .off
                device.unlockForConfiguration()
            }
            catch{
                print("Error")
            }
        }
    }
    
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 60/Double(fre), target: self, selector: #selector(self.twinkle), userInfo: nil, repeats: true)
    }
    
    @objc func twinkle() {
        if let device = AVCaptureDevice.default(for: AVMediaType.video), device.hasTorch{
            do{
                try device.lockForConfiguration()
                if(device.torchMode == .on){
                    device.torchMode = .off
                }
                else{
                    device.torchMode = .on
                }
                device.unlockForConfiguration()
            }
            catch{
                print("Error")
            }
        }
    }
    
}

