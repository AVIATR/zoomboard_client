//
//  MenuViewController.swift
//  AVPlayerTest
//
//  Created by Giovanni Fusco on 5/11/19.
//  Copyright © 2019 SKERI. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var welcomeText: UIView!
    
    @IBOutlet weak var connectView: UIView!
    

    var ipAddress_highres : String {
        get {
        // Get the standard UserDefaults as "defaults"
        let defaults = UserDefaults.standard
            return defaults.string(forKey: "ipAddress_highres") ?? Movies.hRes()
//            return
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
            return defaults.string(forKey: "ipAddress_lowres") ?? Movies.lRes()
//            return

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
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var lectureNameTextBox: UITextField!
    
    @IBOutlet weak var bottomRef: UILabel!
    @IBOutlet weak var topRef: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.connectView.alpha = 0
        self.welcomeText.alpha = 0
        showWelcomeText()
        lectureNameTextBox.delegate = self
        lectureNameTextBox.text = lectureName
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width

        bottomView.frame.origin.y =   screenWidth - bottomView.bounds.height
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        joinLecturePressed(self)
        return false

    }
    
    @IBAction func isEditing(_ sender: Any) {
        
        lectureNameTextBox.backgroundColor = UIColor.white
        lectureName = lectureNameTextBox.text ?? "Lecture"
    }
    
    @IBAction func lectureNameEditingBegan(_ sender: Any) {
       
        scrollView.scrollRectToVisible(bottomRef.frame, animated: true)
    }
    @IBAction func lectureNameEditingEnded(_ sender: Any) {
      scrollView.scrollRectToVisible(topRef.frame, animated: true)
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
                    viewController.modalPresentationStyle = .overFullScreen
                    viewController.MenuViewContDelegate = self
                    viewController.highResURL = self.ipAddress_highres
                    viewController.lowResURL = self.ipAddress_lowres
                }
            }
            else if identifier == "StreamVideo"{
                if let viewController = segue.destination as? ViewController {
                    print(ipAddress_highres)
                    print(ipAddress_lowres)
                    
                    viewController.highResStream = URL(string: self.ipAddress_highres)!
                    viewController.lowResStream = URL(string: self.ipAddress_lowres)!
                    viewController.lectureName = self.lectureName
                }
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
