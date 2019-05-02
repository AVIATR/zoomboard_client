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
    @IBOutlet var subView: MPSVideoView!
    
    @IBOutlet var filtersButton: UIButton!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var saveFrameButton: UIButton!

    
    @IBOutlet weak var lectureLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    
    // @IBOutlet weak var lectureNameLabel: UILabel!
    var filtersManager : FiltersManager = FiltersManager()

    var scaledState : Bool = false
    var continueLecture : Bool = false
  

    @IBOutlet weak var curImageView: UIImageView!
    
    var viewCentre: CGPoint = CGPoint.init()
    var streamURL : URL = URL(string:"https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")!
//    var streamURL : URL = URL(string:"http://www.wowza.com/_h264/BigBuckBunny_115k.mov")!
    
    var lectureName : String = "default"
    



    @IBOutlet weak var superView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        superView.clipsToBounds = true
        

        // TODO: show modal window to connect to stream
        filtersManager.initializeFilters(filtersView : filtersView)
        subView.setFiltersManager(filtersManager : filtersManager)
        // we set up the streamURL here
//        streamURL = URL(string: "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")!
        // once connected, set up folder for the session
        viewCentre =  superView.center
        lectureLabel.text = lectureName
        urlLabel.text = streamURL.absoluteString
        stopButton.isHidden = true
        startButton.isHidden = false
        createAlbum()
        
    }

    /** Creates a photo album with title lecturename.
     
     :returns: Nothing
     */
    func createAlbum() {
        SDPhotosHelper.createAlbum(withTitle: lectureName) { (true, error) in
        }
    }

    @IBAction func resetViewButton(_ sender: Any) {
        subView.center = viewCentre
        subView.transform = CGAffineTransform.identity
        
    }
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        if let view = recognizer.view {
            
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
            print("subView")
          //  print(view.center)
            print(view.frame)
            
            print("superView")
         //   print(superView.center)
            
            print(superView.bounds)
            print(" ")
            if view.frame.minX > 0 {
                view.center.x = view.center.x - view.frame.minX
            }
            if view.frame.minY > 0 {
                view.center.y = view.center.y - view.frame.minY
            }
            if view.frame.maxX < superView.bounds.width {
                view.center.x = view.center.x + (superView.bounds.width - view.frame.maxX)
            }
            if view.frame.maxY <  superView.bounds.height {
                view.center.y = view.center.y + (superView.bounds.height - view.frame.maxY)
            }

        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }

    @IBAction func handlePinch(recognizer:UIPinchGestureRecognizer) {
        
        if let view = recognizer.view {
            if view.contentScaleFactor <= 1.0 && recognizer.scale < 1{
                return
            }
            view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
            
            print("subView")
            print(view.center)
            print(view.frame)
            print(view.bounds)
            print("superView")
            print(superView.center)
            print(superView.frame)
            print(superView.bounds)

            if view.frame.maxX - view.frame.minX < superView.frame.width {
                subView.transform = CGAffineTransform.identity
            }

            if view.frame.minX > 0 {
                view.center.x = view.center.x - view.frame.minX
            }
            if view.frame.minY > 0 {
                view.center.y = view.center.y - view.frame.minY
            }
            if view.frame.maxX < superView.bounds.width {
                view.center.x = view.center.x + (superView.bounds.width - view.frame.maxX)
            }
            if view.frame.maxY <  superView.bounds.height {
                view.center.y = view.center.y + (superView.bounds.height - view.frame.maxY)
            }

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
                
                view.center = viewCentre
                
                view.transform = view.transform.scaledBy(x: 2, y: 2)
                scaledState = true
                return
            }
            
            if scaledState == true {
                print("by 1/2")

                subView.center = viewCentre
                subView.transform = CGAffineTransform.identity
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
        stopButton.isHidden = false
        startButton.isHidden = true
        subView.play(stream: streamURL, fps: 30) {
            self.subView.player.isMuted = true
        }
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        stopButton.isHidden = true
        startButton.isHidden = false
        subView.stop()
 //       videoView.sizeToFit()
 //       videoView.transform = view.transform.scaledBy(x: videoView.contentScaleFactor, y: videoView.contentScaleFactor)


    }
    /** Saves image to photo album with title lecturename when the snapshot button is pressed, using SDPhotosHelper module. If the action succeeds, the program presents UIAlertController confirming success; otherwise, the program throws an error.
     
     :_ sender: UIButton "Snapshot"
     
     :returns: Nothing
     */
    
    
    @IBAction func saveFrameButtonPressed(_ sender: Any) {
        //TODO
        // Plug Matthew's code
        // Trouble unwrapping video.currentImage, replaced with imageview.image
        curImageView.image = subView.getCurrentImage()
        SDPhotosHelper.addNewImage(subView.getCurrentImage(), toAlbum: lectureName, onSuccess: { _ in
            let alert = UIAlertController(title: "Success!", message: "Your photo was stored in the album titled \(self.lectureName)", preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil
            ))

            self.present(alert, animated: true, completion: nil)
        }, onFailure: { (error) in
        })

    }
}
