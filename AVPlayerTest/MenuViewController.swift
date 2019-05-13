//
//  MenuViewController.swift
//  AVPlayerTest
//
//  Created by Giovanni Fusco on 5/11/19.
//  Copyright © 2019 SKERI. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, ModalViewControllerDelegate {

    @IBOutlet weak var welcomeText: UIView!
    
    @IBOutlet weak var connectView: UIView!
    

    var ipAddress : String {
        get {
        // Get the standard UserDefaults as "defaults"
        let defaults = UserDefaults.standard
            return defaults.string(forKey: "ipAddress") ?? "https://127.0.0.1"
        }
        set (newValue) {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "ipAddress")
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
        self.overlayBlurredBackgroundView()
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
        lectureName = lectureNameTextBox.text ?? "Lecture"
    }
    @IBAction func joinLecturePressed(_ sender: Any) {
        performSegue(withIdentifier: "StreamVideo", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier {
            if identifier == "settingsModalView" {
                if let viewController = segue.destination as? SettingsView {
                    viewController.delegate = self
                    viewController.modalPresentationStyle = .overFullScreen
                    viewController.ipAddress = self.ipAddress
                }
            }
            else if identifier == "StreamVideo"{
                if let viewController = segue.destination as? ViewController {
                    viewController.streamURL = URL(string: ipAddress)!
                    viewController.lectureName = self.lectureName
                }
            }
        }
    }
    
    
    
    func overlayBlurredBackgroundView() {
        
        let blurredBackgroundView = UIVisualEffectView()
        
        blurredBackgroundView.frame = view.frame
        blurredBackgroundView.effect = UIBlurEffect(style: .extraLight)
        view.addSubview(blurredBackgroundView) 
    }
    
    func removeBlurredBackgroundView() {
        
        for subview in view.subviews {
            if subview.isKind(of: UIVisualEffectView.self) {
                subview.removeFromSuperview()
            }
        }
    }
    
}
