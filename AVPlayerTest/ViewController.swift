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
  
    @IBOutlet weak var streamButton: UISwitch!
    
    @IBOutlet var filtersView: UIView!
    @IBOutlet var playerView: MPSVideoView!
    
   
    
    @IBOutlet weak var lectureLabel: UILabel!
    
    @IBOutlet weak var snapshotButton: UIButton!
    
    var filtersManager : FiltersManager = FiltersManager()

    var scaledState : Bool = false
    var continueLecture : Bool = false
    var isPlaying : Bool = false
    var zoomFactor : CGFloat = 1
    var playerOriginalSize : CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    var screenHeight : CGFloat = 0
    var screenWidth : CGFloat = 0
    var isStarting: Bool = true
    
    var videoSize : CGSize = CGSize(width: 0, height: 0)
    let barHeight  : CGFloat = 44.0 // player bar height

    @IBOutlet weak var snapshotImageView: UIImageView!
    
    var viewCenter: CGPoint = CGPoint.init()
    
    var highResStream : URL = URL(string: "default")!
    var lowResStream : URL = URL(string: "default")!
    
    var lectureName : String = "default"
    var streamURL : URL = URL(string: "default")!

    @IBOutlet weak var streamSwitch: UISwitch!
    @IBOutlet weak var superView: UIView!
    

    @IBOutlet var tapGesture: UITapGestureRecognizer!
    override func viewDidLoad() {
        super.viewDidLoad()
        tapGesture.numberOfTapsRequired = 2
        tapGesture.numberOfTouchesRequired = 1
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

        //Register for the applicationWillResignActive anywhere in your app.
        
        superView.clipsToBounds = true
        
        filtersManager.initializeFilters(filtersView : filtersView)
        playerView.setFiltersManager(filtersManager : filtersManager)
        playerView.delegateView = self
        viewCenter =  superView.center
        lectureLabel.text = lectureName

        // set up player bar to always be at the bottom and span the entire width of the screen
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
       
        streamURL = highResStream
//        setupUI()
        startStream()
        
        // once connected, set up folder for the session
        createAlbum()
 
        setupUI()
        
    }
    @objc func appMovedToBackground() {
        print("App moved to background!")
        print("Player Stopped")
        self.playerView.stop()
    }
    @objc func appMovedToForeground() {
        print("App moved to Foreground!")
        print("Player Started")
        playerView.play(stream: streamURL, fps: 30){
            self.playerView.player.isMuted = true
        }
    }
    /** Creates a photo album with title lecturename.
     
     :returns: Nothing
     */
    func fail()-> Void{
        
    }
    func createAlbum() {
        SDPhotosHelper.createAlbum(withTitle: lectureName) { (true, error) in
        }
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
//---------------------------------------------------------
    @IBAction func toggleStreamSwitch(_ sender: Any) {
        playerView.stop()
        streamURL = streamSwitch.isOn ? highResStream : lowResStream
        playerView.play(stream: streamURL, fps: 30){
            self.playerView.player.isMuted = true
        }
        
    }
//---------------------------------------------------------
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        if zoomFactor > 1{
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
            UIView.animate(withDuration: TimeInterval(0.1), delay: 0, options: .curveLinear, animations: {
                self.playerView.frame = CGRect(x: newX, y: newY, width: self.playerView.frame.width, height: self.playerView.frame.height)
                
            }, completion: nil )
            
        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }

    @IBAction func handlePinch(recognizer:UIPinchGestureRecognizer) {
        
        // this is used to keep track of the cumulative level of zoom
        zoomFactor -=  1 - recognizer.scale
        
        if zoomFactor > 1 && zoomFactor < 2.5{
            let pinchCenter : CGPoint = recognizer.location(in: playerView)
            zoomToLocation(zoomPoint : pinchCenter, zoomFactor : recognizer.scale)
        }
        if zoomFactor <= 1 {
            
            UIView.animate(withDuration: TimeInterval(0.1), delay: 0, options: .curveLinear, animations: {
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
    
    func zoomToLocation(zoomPoint : CGPoint, zoomFactor : CGFloat){
        var pt : CGPoint = zoomPoint
        pt.x -= playerView.bounds.midX
        pt.y -= playerView.bounds.midY
        var tranf = playerView.transform

        playerView.transform = playerView.transform.translatedBy(x: pt.x, y: pt.y).scaledBy(x: zoomFactor, y: zoomFactor).translatedBy(x: -pt.x, y: -pt.y)
//        playerView.transform = playerView.transform.scaledBy(x: zoomFactor, y: zoomFactor)
  //      playerView.transform = playerView.transform.translatedBy(x: -pt.x, y: -pt.y)
    }
    
    
    
    // make player bar disappear when touching video
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lectureLabel.isHidden = !lectureLabel.isHidden
    }
    

    @IBAction func handleDoubletap(recognizer:UITapGestureRecognizer) {
        recognizer.numberOfTapsRequired = 2
        recognizer.numberOfTouchesRequired = 1
        if (zoomFactor > 1){
            UIView.animate(withDuration: TimeInterval(0.4), delay: 0, options: .curveEaseInOut, animations: {
                let ratio = self.playerOriginalSize.width / self.playerView.frame.width
                print(ratio)
                self.playerView.transform = .identity
//                self.playerView.transform = self.playerView.transform.scaledBy(x: ratio, y: ratio)
  //              self.playerView.frame = self.playerOriginalSize
                
                self.zoomFactor = 1
                self.fixView()
                 }, completion: nil )
           
        }
        else{
            UIView.animate(withDuration: TimeInterval(0.4), delay: 0, options: .curveEaseInOut, animations: {
                let zoomPoint = recognizer.location(in: self.playerView)
                self.zoomFactor = 2
                self.zoomToLocation(zoomPoint : zoomPoint, zoomFactor : self.zoomFactor)
                self.fixView()
                }, completion: nil )
        }
    }
    
    func resetZoom(){
        zoomFactor = 1
        let ratio = self.playerOriginalSize.width / self.playerView.frame.width
        
        self.playerView.transform = self.playerView.transform.scaledBy(x: ratio, y: ratio)
        self.playerView.frame = self.playerOriginalSize
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func showFiltersButtonPushed(_ sender: Any) {
        filtersView.isHidden = !filtersView.isHidden
    }

    @objc private func setVideoSize(){
        videoSize = playerView.getOriginalVideoResolution()
    }
    
    func startStream(){
        if !isPlaying{
            isPlaying = true
           
            playerView.play(stream: streamURL, fps: 30){
                self.playerView.player.isMuted = true
            }
            Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(setupUI), userInfo: nil, repeats: false)
            lectureLabel.isHidden = true
        }
    }



    func getImageToSave() -> UIImage{
        
        snapshotImageView.image = playerView.getCurrentImage()
        let size: CGSize = playerView.getOriginalVideoResolution()
        UIGraphicsBeginImageContext(size)
        let areaSize = CGRect(x: 0, y: 0, width: size.width, height:  size.height)
        snapshotImageView.image!.draw(in: areaSize)
        let savedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let img = savedImage {
            return img}
        else {
            return UIImage.init()
        }
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
    
    
    @IBAction func saveSnapshotPushed(_ sender: Any) {
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
        else{
            resetZoom()
        }
        if navigationController == nil
        {
            return
        }
        let navBarHeight = self.navigationController!.navigationBar.frame.size.height

            let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top
        
        let screenSize = UIScreen.main.bounds
        if isStarting == true {
            screenHeight = self.view.frame.size.height// - (navBarHeight + topPadding!)
            screenWidth = self.view.frame.size.width
        }
        else {
            screenHeight = self.view.frame.size.width// - (navBarHeight + topPadding!)
            screenWidth = self.view.frame.size.height
        }
        print("screenHeight = \(screenHeight)")
        print("screenWidth = \(screenWidth)")
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
        
        superView.frame = CGRect(x:0,y:0, width:screenWidth, height:screenHeight)
        lectureLabel.frame = CGRect(x: 0, y: topPadding! + navBarHeight + 5, width: screenWidth, height: lectureLabel.frame.height)
        
        //fit video frame to screen
        setupVideoFrameSize()

        
        // set filters panel position
        let frame = filtersView.frame
        filtersView.frame = CGRect(x: screenWidth-frame.width, y: screenHeight-frame.height-30, width: frame.width, height: frame.height)
            
        
    }
    
    func setupVideoFrameSize(){
        // if we received the first frame, resize video to fit available space on screen
        if (videoSize.width > 0){
            if videoSize.width > videoSize.height{ // landscape video
                setupLandscapeVideo()
            }
            else{
                // @Parag TODO: handle portrait video
                setupPortraitVideo()
            }
            snapshotImageView.frame = playerView.frame
        }
        else if isPlaying{ // if the frame size is not available, keep trying until the first frame arrives
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(setupUI), userInfo: nil, repeats: false)
        }
    }
    
    func setupPortraitVideo(){
       setupLandscapeVideo()
    }
    
    func setupLandscapeVideo(){
        var w : CGFloat = 0
        var h : CGFloat = 0
        let center = superView.center
        let aspectRatio = (screenHeight) / screenWidth
        if aspectRatio > videoSize.height / videoSize.width {
            w = screenWidth
            h = (videoSize.height / videoSize.width) * w
        }
        else{
            h = screenHeight
            w = (videoSize.width / videoSize.height) * screenHeight
        }
        
        let x = center.x - w/2
        let y = center.y - h/2
        playerView.frame = CGRect(x: x, y: y, width: w, height: h)
        playerOriginalSize = playerView.frame
    }
    

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
        }
        else if UIDevice.current.orientation.isFlat {
            print("Flat")
        }
        else {
            print("Portrait")
        }
        isStarting = false
        setupUI()
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear - Player Stopped")
        NotificationCenter.default.removeObserver(self)
        self.playerView.stop()
    }
    
}
