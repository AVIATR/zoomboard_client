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
    
    
    var streamURL : URL = URL(string:"https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")!
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
    
    override func viewDidLoad() {
        super.viewDidLoad() 
        // TODO: show modal window to connect to stream
        filtersManager.initializeFilters(filtersView : filtersView)
        videoView.setFiltersManager(filtersManager : filtersManager)
        // we set up the streamURL here
        streamURL = URL(string: "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")!
        // once connected, set up folder for the session
        
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        videoView.play(stream: streamURL, fps: 30) {
            self.videoView.player.isMuted = true
        }
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        videoView.stop()
    }

    @IBAction func saveFrameButtonPressed(_ sender: Any) {
        //TODO
        // Plug Matthew's code
    }
}
