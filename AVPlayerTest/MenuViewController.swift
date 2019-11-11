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
    var activeField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.connectView.alpha = 0
        self.welcomeText.alpha = 0
        showWelcomeText()
        lectureNameTextBox.delegate = self
        lectureNameTextBox.text = lectureName
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        lectureNameTextBox.delegate = self
        
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
            self.welcomeText.becomeFirstResponder()
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
    
//    @IBAction func lectureNameEditingBegan(_ sender: Any) {
//
//        scrollView.scrollRectToVisible(bottomRef.frame, animated: true)
//    }
//    @IBAction func lectureNameEditingEnded(_ sender: Any) {
//      scrollView.scrollRectToVisible(topRef.frame, animated: true)
//    }
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
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name:
            UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height, right: 0.0)

        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets

        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }

    @objc func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -keyboardSize!.height, right: 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }

    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }

}
