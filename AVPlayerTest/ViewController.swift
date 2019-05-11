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
    @IBOutlet var playerView: MPSVideoView!
    
    @IBOutlet weak var playerBar: UIToolbar!
    @IBOutlet weak var playButton: UIBarButtonItem!
    @IBOutlet weak var snapshotButton: UIBarButtonItem!
    @IBOutlet weak var pauseButton: UIBarButtonItem!
    
    @IBOutlet weak var lectureLabel: UILabel!
    
    
    var filtersManager : FiltersManager = FiltersManager()

    var scaledState : Bool = false
    var continueLecture : Bool = false
    var isPlaying : Bool = false
    var zoomFactor : CGFloat = 1
    var playerOriginalSize : CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    var screenHeight : CGFloat = 0
    var screenWidth : CGFloat = 0
    
    
    var videoSize : CGSize = CGSize(width: 0, height: 0)
    let barHeight  : CGFloat = 44.0 // player bar height

    @IBOutlet weak var snapshotImageView: UIImageView!
    
    var viewCenter: CGPoint = CGPoint.init()
    var streamURL : URL = URL(string:"https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")!
//    var streamURL : URL = URL(string:"http://www.wowza.com/_h264/BigBuckBunny_115k.mov")!
    
    var lectureName : String = "default"
    

    @IBOutlet weak var superView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        superView.clipsToBounds = true
        

        filtersManager.initializeFilters(filtersView : filtersView)
        playerView.setFiltersManager(filtersManager : filtersManager)
        
        viewCenter =  superView.center
        lectureLabel.text = lectureName

        // set up player bar to always be at the bottom and span the entire width of the screen
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        playerBar.frame = CGRect(x:0,y:screenHeight-barHeight, width:screenWidth, height:barHeight)
        
        // once connected, set up folder for the session
        createAlbum()
        setupUI()

    }


    /** Creates a photo album with title lecturename.
     
     :returns: Nothing
     */
    func createAlbum() {
        SDPhotosHelper.createAlbum(withTitle: lectureName) { (true, error) in
        }
    }

    @IBAction func resetViewButton(_ sender: Any) {
        playerView.transform = CGAffineTransform.identity
        playerView.center = superView.center
    }
    
    func fixView(){
        var x = playerView.frame.minX
        if  x > 0{
            x = 0
        }
        else if x < screenWidth - playerView.frame.width{
            x = screenWidth - playerView.frame.width
        }
        let navBarHeight = self.navigationController!.navigationBar.frame.size.height
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top
        let yoffset = navBarHeight + topPadding!
        
        var y = playerView.frame.minY
        if playerView.frame.height > screenHeight{
            y = playerView.frame.minY
            if  y > yoffset{
                y = yoffset
            }
            if y < screenHeight - playerView.frame.height{
                y = screenHeight - playerView.frame.height
            }
        }
        else{
            playerView.center.y = viewCenter.y
        }
        
        playerView.frame = CGRect(x: x, y: y, width: playerView.frame.width, height: playerView.frame.height)
    }
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
//        print(translation)

        if zoomFactor > 1{
//            print(playerView.frame.width)
            var newX : CGFloat = playerView.frame.minX + translation.x
            
            
            if  newX > 0{
                newX = 0
            }
            else if newX < screenWidth - playerView.frame.width{
                newX = screenWidth - playerView.frame.width
            }
            let navBarHeight = self.navigationController!.navigationBar.frame.size.height
            let window = UIApplication.shared.keyWindow
            let topPadding = window?.safeAreaInsets.top
            let yoffset = navBarHeight + topPadding!
            
            var newY = playerView.frame.minY
            if playerView.frame.height > screenHeight{
                newY = playerView.frame.minY + translation.y
                if  newY > yoffset{
                    newY = yoffset
                }
                if newY < screenHeight - playerView.frame.height{
                    newY = screenHeight - playerView.frame.height
                }
            }
            UIView.animate(withDuration: TimeInterval(0.25), delay: 0, options: .curveLinear, animations: {
                self.playerView.frame = CGRect(x: newX, y: newY, width: self.playerView.frame.width, height: self.playerView.frame.height)
                
            }, completion: nil )
            
        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }

    @IBAction func handlePinch(recognizer:UIPinchGestureRecognizer) {
        
        zoomFactor -=  1 - recognizer.scale
        if zoomFactor > 1 && zoomFactor < 2.5{
            playerView.transform = playerView.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
        }
        if zoomFactor <= 1 {
            
            UIView.animate(withDuration: TimeInterval(0.25), delay: 0, options: .curveLinear, animations: {
                self.playerView.frame = self.playerOriginalSize
            }, completion: nil )

            zoomFactor = 1
        }
        else if zoomFactor > 2.5{
            zoomFactor = 2.5
        }
        recognizer.scale = 1
        fixView()
    }
    
    
    // make player bar disappear when touching video
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
////        playerBar.isHidden = !playerBar.isHidden
        lectureLabel.isHidden = !lectureLabel.isHidden
    }
    
   
    

    @IBAction func handleDoubletap(recognizer:UITapGestureRecognizer) {
        UIView.animate(withDuration: TimeInterval(0.25), delay: 0, options: .curveLinear, animations: {
            self.playerView.frame = self.playerOriginalSize
             }, completion: nil )
        fixView()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

     
    
    @IBAction func showFiltersPanel(_ sender: UIBarButtonItem) {
        sender.tintColor = UIColor(named: "red")
        sender.image = UIImage(named: "equalizer_icon_selected.png")
        filtersView.isHidden = !filtersView.isHidden
    }
    

   @objc private func setVideoSize(){
        videoSize = playerView.getOriginalVideoResolution()
    }
        
    
    @IBAction func playButtonPressed(_ sender: UIBarButtonItem) {
        if !isPlaying{
            isPlaying = true
            playButton.image =  UIImage()
            playerView.play(stream: streamURL, fps: 30){
                self.playerView.player.isMuted = true
            }
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(setupUI), userInfo: nil, repeats: false)
//            playerBar.isHidden = true
            lectureLabel.isHidden = true
        }
    }
    
    @IBAction func pauseButtonPressed(_ sender: UIBarButtonItem) {
        if isPlaying{
            playerView.stop()
            isPlaying = false
        }
    }

    /** Saves image to photo album with title lecturename when the snapshot button is pressed, using SDPhotosHelper module. If the action succeeds, the program presents UIAlertController confirming success; otherwise, the program throws an error.
     
     :_ sender: UIButton "Snapshot"
     
     :returns: Nothing
     */
    
    // TODO: save zoomed and panned image?
    func getImageToSave() -> UIImage{
        
        snapshotImageView.image = playerView.getCurrentImage()
        var size: CGSize
        if (UIDevice.current.orientation.isLandscape) {
            size = CGSize(width: playerView.bounds.width, height: playerView.bounds.height)
        } else {
            size = CGSize(width: playerView.bounds.height, height: playerView.bounds.width)
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
    
    
    @objc func setupUI(){
        
        if (videoSize.width == 0){
            setVideoSize()
        }
        
        let navBarHeight = self.navigationController!.navigationBar.frame.size.height
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top
        
        let screenSize = UIScreen.main.bounds
        screenHeight = self.view.frame.size.height// - (navBarHeight + topPadding!)
        screenWidth = self.view.frame.size.width
        
        // this is a workaround for when device is flat
        if (screenSize.height > screenSize.width){ // screen orientation is portrait
            if self.view.frame.size.height < self.view.frame.size.width{
                screenHeight = self.view.frame.size.width// - (navBarHeight + topPadding!)
                screenWidth = self.view.frame.size.height
            }
        }
        if (screenSize.width > screenSize.height){ // screen orientation is landscaspe
            if self.view.frame.size.width < self.view.frame.size.height{
                screenHeight = self.view.frame.size.width// - (navBarHeight + topPadding!)
                screenWidth = self.view.frame.size.height
            }
        }
        
        let ypos = navBarHeight+topPadding!
//        print(screenWidth, screenHeight, ypos)
//        print(navBarHeight, topPadding!)
        
        
        superView.frame = CGRect(x:0,y:0, width:screenWidth, height:screenHeight)
        
        lectureLabel.frame = CGRect(x: 0, y: topPadding! + navBarHeight + 5, width: screenWidth, height: lectureLabel.frame.height)
        
        // if we received the first frame
        if (videoSize.width > 0){
            
            //resize player view to fit video stream
            // determine if video is landscape or portrait
            if videoSize.width > videoSize.height{ // landscape video
                setupLandscapeVideo(screenHeight : screenHeight, screenWidth : screenWidth, navBarHeight : navBarHeight)
            }
            else{
                // @Parag TODO: handle portrait video
                setupPortraitVideo(screenHeight : screenHeight, screenWidth : screenWidth, navBarHeight : navBarHeight)
            }
        }
        else if isPlaying{ // if the frame size is not available, keep trying until the first frame arrives
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(setupUI), userInfo: nil, repeats: false)
        }
        
        
        // set filters panel position
        let frame = filtersView.frame
        filtersView.frame = CGRect(x: screenWidth-frame.width, y: screenHeight-frame.height, width: frame.width, height: frame.height)
        
    }
    
    func setupPortraitVideo(screenHeight : CGFloat, screenWidth : CGFloat, navBarHeight : CGFloat){
        
        print("!!! IMPLEMENT METHOD")
    }
    
    
    func setupLandscapeVideo(screenHeight : CGFloat, screenWidth : CGFloat, navBarHeight : CGFloat){
        var w : CGFloat = 0
        var h : CGFloat = 0
        let center = superView.center
        let aspectRatio = (screenHeight) / screenWidth
        
        if (UIDevice.current.orientation.isPortrait){
            w = screenWidth
            h = (screenHeight) * (videoSize.height / videoSize.width)
        }
        else {
            if aspectRatio > videoSize.height / videoSize.width {
                w = screenWidth
                h = (videoSize.height / videoSize.width) * w
            }
            else{
                h = screenHeight
                w = (videoSize.width / videoSize.height) * screenHeight
            }
        }
        let x = center.x - w/2
        let y = center.y - h/2
        playerView.frame = CGRect(x: x, y: y, width: w, height: h)
        playerOriginalSize = playerView.frame
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator){
        super.viewWillTransition(to: size, with: coordinator)
        setupUI()
    }
}
