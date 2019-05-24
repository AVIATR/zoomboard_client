//
//  MenuViewController.swift
//  AVPlayerTest
//
//  Created by Giovanni Fusco on 5/11/19.
//  Copyright © 2019 SKERI. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var welcomeText: UIView!
    
    @IBOutlet weak var connectView: UIView!
    

    var ipAddress_highres : String {
        get {
        // Get the standard UserDefaults as "defaults"
        let defaults = UserDefaults.standard
            return defaults.string(forKey: "ipAddress_highres") ?? "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"
        }
        set (newValue) {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "ipAddress_highres")
        }
    }
    
    var ipAddress_lowres : String {
        get {
            // Get the standard UserDefaults as "defaults"
            let defaults = UserDefaults.standard
            return defaults.string(forKey: "ipAddress_lowres") ?? "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"
        }
        set (newValue) {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "ipAddress_lowres")
        }
    }
    
    var lectureName : String {
        get {
            // Get the standard UserDefaults as "defaults"
            let defaults = UserDefaults.standard
            return defaults.string(forKey: "lectureName") ?? "New Lecture"
        }
        set (newValue) {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "lectureName")
        }
    }
    
    @IBOutlet weak var lectureNameTextBox: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.connectView.alpha = 0
        self.welcomeText.alpha = 0
        showWelcomeText()
        lectureNameTextBox.text = lectureName

    }
    
    func fadeInOutView(view : UIView, duration: TimeInterval, delay : TimeInterval){
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            view.alpha = 1 - view.alpha
        }, completion: nil)
    }
    
    @IBAction func showSettingsView(_ sender: Any) {
        self.definesPresentationContext = true
        self.providesPresentationContextTransitionStyle = true
//        self.overlayBlurredBackgroundView()
        performSegue(withIdentifier: "settingsModalView", sender: nil)
    }
    
    
    func showWelcomeText(){
        UIView.animate(withDuration: 1, animations: { () -> Void in
            self.welcomeText.alpha = 1
        })
        UIView.animate(withDuration: 1, delay: TimeInterval(0.5), options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.connectView.alpha = 1.0
        }, completion: nil)
    }
    
    
    @IBAction func isEditing(_ sender: Any) {
        lectureNameTextBox.backgroundColor = UIColor.white
        lectureName = lectureNameTextBox.text ?? "Lecture"
    }
    @IBAction func joinLecturePressed(_ sender: Any) {
        if lectureNameTextBox.text?.isEmpty == false{
            performSegue(withIdentifier: "StreamVideo", sender: nil)
        }
        else{
            lectureNameTextBox.backgroundColor = UIColor.red
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier {
            if identifier == "settingsModalView" {
                if let viewController = segue.destination as? SettingsView {
                    viewController.highResURL = self.ipAddress_highres
                    viewController.lowResURL = self.ipAddress_lowres
                }
            }
            else if identifier == "StreamVideo"{
                if let viewController = segue.destination as? ViewController {
                    viewController.highResStream = URL(string: self.ipAddress_highres)!
                    viewController.lowResStream = URL(string: self.ipAddress_lowres)!
                    viewController.lectureName = self.lectureName
                }
            }
        }
    }
    
}
