//
//  ViewController.swift
//  AVPlayerTest
//
//  Created by Giovanni Fusco on 1/31/19.
//  Copyright © 2019 SKERI. All rights reserved.
//

import UIKit
import AVKit
import Photos
import AVFoundation

class ViewController: UIViewController {
  
    
    @IBOutlet var filtersView: UIView!
    @IBOutlet var subView: MPSVideoView!
    
    @IBOutlet var filtersButton: UIButton!

    @IBOutlet weak var playButton: UIBarButtonItem!
    @IBOutlet weak var snapshotButton: UIBarButtonItem!
    @IBOutlet weak var pauseButton: UIBarButtonItem!
    
    @IBOutlet weak var lectureLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    
    var filtersManager : FiltersManager = FiltersManager()

    var scaledState : Bool = false
    var continueLecture : Bool = false
    var isPlaying : Bool = false

    @IBOutlet weak var snapshotImageView: UIImageView!
    
    var viewCentre: CGPoint = CGPoint.init()
    var streamURL : URL = URL(string:"https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")!
//    var streamURL : URL = URL(string:"http://www.wowza.com/_h264/BigBuckBunny_115k.mov")!
    
    var lectureName : String = "default"

    @IBOutlet weak var superView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        superView.clipsToBounds = true
        

        filtersManager.initializeFilters(filtersView : filtersView)
        subView.setFiltersManager(filtersManager : filtersManager)
        // we set up the streamURL here
//        streamURL = URL(string: "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")!

        viewCentre =  superView.center
        lectureLabel.text = lectureName
//        urlLabel.text = streamURL.absoluteString

        // once connected, set up folder for the session
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
        subView.transform = CGAffineTransform.identity
        subView.center = superView.center
        
        
        
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
     
    
    @IBAction func showFiltersPanel(_ sender: UIBarButtonItem) {
        sender.tintColor = UIColor(named: "red")
        
        sender.image = UIImage(named: "equalizer_icon_selected.png")
        
        // move player when showing or hiding the filters panel
        if (filtersView.isHidden){
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear, animations: {
                self.superView.center.x -= 100
            }
                , completion: nil
            )
        }
        else{
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear, animations: {
                self.superView.center.x += 100
            }
                , completion: nil
            )
        }
        
        filtersView.isHidden = !filtersView.isHidden
    }
    
        
        
    
    @IBAction func playButtonPressed(_ sender: UIBarButtonItem) {
        if !isPlaying{
            isPlaying = true
            playButton.image =  UIImage()
            subView.play(stream: streamURL, fps: 30){
                self.subView.player.isMuted = true
            }
        }
    }
    
    @IBAction func pauseButtonPressed(_ sender: UIBarButtonItem) {
        if isPlaying{
            subView.stop()
            isPlaying = false
        }
    }

    /** Saves image to photo album with title lecturename when the snapshot button is pressed, using SDPhotosHelper module. If the action succeeds, the program presents UIAlertController confirming success; otherwise, the program throws an error.
     
     :_ sender: UIButton "Snapshot"
     
     :returns: Nothing
     */
    
    // TODO: save zoomed and panned image?
    func getImageToSave() -> UIImage{
        
        snapshotImageView.image = subView.getCurrentImage()
        var size: CGSize
        if (UIDevice.current.orientation.isLandscape) {
            size = CGSize(width: subView.bounds.width, height: subView.bounds.height)
        } else {
            size = CGSize(width: subView.bounds.height, height: subView.bounds.width)
        }
        UIGraphicsBeginImageContext(size)
        let areaSize = CGRect(x: 0, y: 0, width: size.width, height:  size.height)
        snapshotImageView.image!.draw(in: areaSize)
        let savedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return savedImage!
    }
    
    func playImageSaveAnimation(offset : CGPoint, duration: Float, delay: Float){
        self.snapshotImageView.isHidden = false
        UIView.animate(withDuration: TimeInterval(duration), delay: 0, options: .curveLinear, animations: {
            self.snapshotImageView.center.x += offset.x
            self.snapshotImageView.center.y += offset.y
            self.snapshotImageView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            
        }, completion: { _ in
            self.snapshotImageView.isHidden = true
            self.snapshotImageView.center.x -= offset.x
            self.snapshotImageView.center.y -= offset.y
            self.snapshotImageView.transform = CGAffineTransform.identity
        })
    }
    
    
    @IBAction func saveSnapshotPressed(_ sender: Any) {
        let imageToSave = getImageToSave()
        SDPhotosHelper.addNewImage(imageToSave, toAlbum: lectureName, onSuccess: { _ in
             // animate snapshot
            let offset = CGPoint(x:-500, y:-500)
            self.playImageSaveAnimation(offset: offset, duration: 0.25, delay: 0.0)

        }, onFailure: { (error) in
        })
    }
}
