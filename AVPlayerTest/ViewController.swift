//
//  ViewController.swift
//  AVPlayerTest
//
//  Created by Giovanni Fusco on 1/31/19.
//  Copyright © 2019 SKERI. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {
  
    
    @IBOutlet var filtersView: UIView!
    
    @IBOutlet var filtersButton: UIButton!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var saveFrameButton: UIButton!
    @IBOutlet var videoView: MPSVideoView!
    
    var filtersManager : FiltersManager = FiltersManager()

    var scaledState : Bool = false

    var viewcentre: CGPoint = CGPoint.init()
    var streamURL : URL = URL(string:"https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")!
    
    @IBOutlet weak var txtAddItem: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: show modal window to connect to stream
        filtersManager.initializeFilters(filtersView : filtersView)
        videoView.setFiltersManager(filtersManager : filtersManager)
        // we set up the streamURL here
        streamURL = URL(string: "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")!
        // once connected, set up folder for the session
        viewcentre =  videoView.center
        
    }
    @IBAction func didTapButton(_ sender: Any) {
        if let text = txtAddItem.text {
            if text == "" {
                return
            }
            streamURL = URL(string: txtAddItem.text ?? "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")!
            txtAddItem.resignFirstResponder()
        }

    }
    
    @IBAction func resetViewButton(_ sender: Any) {
        videoView.center = viewcentre
        videoView.transform = CGAffineTransform.identity
        
    }
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }

    @IBAction func handlePinch(recognizer:UIPinchGestureRecognizer) {
        
        if let view = recognizer.view {
            view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
        }
  //      recognizer.reset()
    }

    @IBAction func handleDoubletap(recognizer:UITapGestureRecognizer) {
        print(recognizer.isEnabled)
        recognizer.numberOfTapsRequired = 2
        recognizer.numberOfTouchesRequired = 1

        if let view = recognizer.view {
            
            if scaledState == false {
                print("by 2")
                
                view.center = viewcentre
                
                view.transform = view.transform.scaledBy(x: 2, y: 2)
                scaledState = true
                return
            }
            
            if scaledState == true {
                print("by 1/2")

                videoView.center = viewcentre
                videoView.transform = CGAffineTransform.identity
                scaledState = false
                return
            }

//            recognizer.reset()
        }
        //      recognizer.reset()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

    //    let streamURL = URL(string: "http://10.141.48.129:8080/hls/stream.m3u8")!
   
    @IBAction func filtersButtonPressed(_ sender: UIButton) {
        filtersView.isHidden = !filtersView.isHidden
        if (filtersView.isHidden){
            sender.setTitle("Filters >>" , for: .normal)
        }
        else{
            sender.setTitle("Filters <<" , for: .normal)
        }
    }
    

    
    @IBAction func startButtonPressed(_ sender: Any) {
        videoView.play(stream: streamURL, fps: 30) {
            self.videoView.player.isMuted = true
        }
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        videoView.stop()
 //       videoView.sizeToFit()
 //       videoView.transform = view.transform.scaledBy(x: videoView.contentScaleFactor, y: videoView.contentScaleFactor)


    }

    @IBAction func saveFrameButtonPressed(_ sender: Any) {
        //TODO
        // Plug Matthew's code
    }
}
