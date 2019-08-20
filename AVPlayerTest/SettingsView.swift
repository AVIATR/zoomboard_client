//
//  SettingView.swift
//  AVPlayerTest
//
//  Created by Giovanni Fusco on 5/12/19.
//  Copyright © 2019 SKERI. All rights reserved.
//

import UIKit
import MetalKit
import MetalPerformanceShaders
import AVKit

protocol ModalViewControllerDelegate: class {
    func removeBlurredBackgroundView()
}

class SettingsView: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var urlHighResTextField: UITextField!
    @IBOutlet weak var urlLowResTextField: UITextField!
    
    @IBOutlet weak var lowResImgStatus: UIImageView!
    @IBOutlet weak var highResImgStatus: UIImageView!
    
    var lowResTimer : Timer? = Timer.init(timeInterval: 1, target: self, selector: #selector(runLow), userInfo: nil, repeats: false)
    var highResTimer : Timer? = Timer.init(timeInterval: 1, target: self, selector: #selector(runHigh), userInfo: nil, repeats: false)

    var highResDef : String = Movies.hRes()
    var lowResDef : String = Movies.lRes()
    
    var highResURL : String = ""
    var lowResURL : String = ""

    var highResValidity: Bool = true
    var lowResValidity : Bool = true

    var isHighResTaskCompleated: Bool = true
    var isLowResTaskCompleated: Bool = true

    var highResMessage : String = ""
    var lowResMessage : String = ""
    
    var highResHTTPCode : Int = 0
    var lowResHTTPCode : Int = 0

    weak var MenuViewContDelegate: MenuViewController?
    var throwAlert : Bool = false
    

    @IBOutlet weak var srollViewOutlet: UIScrollView!
    @IBOutlet weak var OKbutton: UIButton!

    @IBOutlet weak var topRect: UILabel!
    @IBOutlet weak var topKeyboardLimit: UILabel!
    @IBOutlet weak var keyboardText: UILabel!
    private var playerItemObserver: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        OKbutton.setTitleColor(.gray, for: .disabled)
        highResValidity = true
        lowResValidity = true
        
        srollViewOutlet.showsVerticalScrollIndicator = false
        srollViewOutlet.showsHorizontalScrollIndicator = false

        srollViewOutlet.isPagingEnabled = false
        srollViewOutlet.isScrollEnabled = false

        urlHighResTextField.text = highResURL
        urlLowResTextField.text = lowResURL

//        highResTextEntered(self)
//        lowResTextEntered(self)

    }
    // -----------------------------------------------------------------
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    @IBAction func resetPressed(_ sender: Any) {
        urlHighResTextField.text = highResDef
        urlLowResTextField.text = lowResDef
//        highResTextEntered(sender)
//        lowResTextEntered(sender)
        isHighResTaskCompleated = true
        isLowResTaskCompleated = true
    }
    @IBAction func cancelPressed(_ sender: Any) {
        isHighResTaskCompleated = true
        isLowResTaskCompleated = true
        invalidateLowResTimer()
        invalidateHighResTimer()
        dismiss(animated: true, completion: nil)
  //      delegate?.removeBlurredBackgroundView()
    }
    @IBAction func editingStarted(_ sender: UITextField) {
        sender.backgroundColor = UIColor.white
        if sender == urlLowResTextField {
            srollViewOutlet.scrollRectToVisible(keyboardText.frame, animated: true)
        }
    }
    
    // OK botton is pressed if enabled
    // -----------------------------------------------------------------
    @IBAction func acceptChanges(_ sender: Any) {
        
        isHighResTaskCompleated = true
        isLowResTaskCompleated = true

        if self.lowResValidity == false || self.highResValidity == false {
            OKbutton.titleLabel?.textColor = UIColor.gray
            OKbutton.isEnabled = false
            return
        }

        if urlLowResTextField.text?.isEmpty == false && urlHighResTextField.text?.isEmpty == false{

            urlLowResTextField.text = urlLowResTextField.text?.sanitize()
            urlHighResTextField.text = urlHighResTextField.text?.sanitize()
            
            if canOpenURL(urlLowResTextField.text)==false{
                AJAlertController.initialization().showAlertWithOkButton(title:"Settings",aStrMessage: "Please enter a valid Low Resolution URL") { (index, title) in
                    print(index,title)
                    if index == 0 {
                    }
                }
                return
            }
            if canOpenURL(urlHighResTextField.text)==false{
                AJAlertController.initialization().showAlertWithOkButton(title:"Settings",aStrMessage: "Please enter a valid High Resolution URL") { (index, title) in
                    print(index,title)
                    if index == 0 {
                    }
                }
                return
            }

            MenuViewContDelegate?.ipAddress_highres = urlHighResTextField.text!
            MenuViewContDelegate?.ipAddress_lowres = urlLowResTextField.text!
            dismiss(animated: true, completion: nil)
        }
        else{
            if urlLowResTextField.text?.isEmpty == true{
                urlLowResTextField.backgroundColor = UIColor.red
            }
            if urlHighResTextField.text?.isEmpty == true{
                urlHighResTextField.backgroundColor = UIColor.red
            }
        }
    }


    // Calls just after text is entered in High and Low Res URLs
    // -----------------------------------------------------------------
    @IBAction func highResTextEntered(_ sender: Any) {
        
        srollViewOutlet.scrollRectToVisible(topRect.frame, animated: true)
        highResImgStatus.image = UIImage(named: "sync")
        highResImgStatus.isHidden = false
        highResValidity = true
        isHighResTaskCompleated =  false
     //   highResTimer?.fire()
        self.validateHighResURL(sender)
    }
    
    @IBAction func lowResTextEntered(_ sender: Any) {
        
        srollViewOutlet.scrollRectToVisible(topRect.frame, animated: true)
        lowResValidity = true
        lowResImgStatus.image = UIImage(named: "sync")
        lowResImgStatus.isHidden = false
        isLowResTaskCompleated =  false
       // lowResTimer?.fire()
        self.validateLowResURL(sender)
    }

    // Validates both the URLs
    // -----------------------------------------------------------------
    @IBAction func validateHighResURL(_ sender: Any) {
        
        if urlHighResTextField.text?.isEmpty == false{
            urlHighResTextField.text = urlHighResTextField.text?.sanitize()
            if throwAlerts(URL : urlHighResTextField.text!, TypeofURL: "High") == false{
                isHighResTaskCompleated = true
                invalidateHighResTimer()
                return
            }
            getHighResURLResponse(urlPath: urlHighResTextField.text!, TypeofURL: "High")
        }
        else {
            highResImgStatus.image = UIImage(named: "cross")
            OKbutton.isEnabled = false
            highResValidity = false
            isHighResTaskCompleated = true
            invalidateHighResTimer()
            let popUpTitle = "Empty URL"
            let popUpMessage = "Please enter a URL"
            AJAlertController.initialization().showAlertWithOkButton(title:popUpTitle,aStrMessage: popUpMessage) { (index, title) in
                print(index,title)
                if index == 0 {
                }
            }
        }
    }
    
    @IBAction func validateLowResURL(_ sender: Any) {
        
        if urlLowResTextField.text?.isEmpty == false {
            urlLowResTextField.text = urlLowResTextField.text?.sanitize()
            if throwAlerts(URL : urlLowResTextField.text!, TypeofURL: "Low") == false {
                isLowResTaskCompleated =  true
                invalidateLowResTimer()
                return
            }
            getLowResURLResponse(urlPath: urlLowResTextField.text!, TypeofURL: "Low")
        }
        else {
            lowResImgStatus.image = UIImage(named: "cross")
            OKbutton.isEnabled = false
            lowResValidity = false
            isLowResTaskCompleated =  true
            invalidateLowResTimer()
            let popUpTitle = "Empty URL"
            let popUpMessage = "Please enter a URL"
            AJAlertController.initialization().showAlertWithOkButton(title:popUpTitle,aStrMessage: popUpMessage) { (index, title) in
                print(index,title)
                if index == 0 {
                }
            }
        }
    }
    
    // Helper functions for Throwing alerts for string errors
    // -----------------------------------------------------------------
    func throwAlerts(URL : String,TypeofURL : String)-> Bool{
        if canOpenURL(URL)==false{
            if TypeofURL == "High"{
                highResImgStatus.image = UIImage(named: "cross")
                highResValidity = false
                isHighResTaskCompleated = true
                invalidateHighResTimer()
            }
            else {
                lowResValidity = false
                lowResImgStatus.image = UIImage(named: "cross")
                isLowResTaskCompleated = true
                invalidateLowResTimer()
            }
            AJAlertController.initialization().showAlertWithOkButton(title:"Settings",aStrMessage: "Please enter a valid \(TypeofURL) Resolution URL") { (index, title) in
                print(index,title)
                if index == 0 {
                }
            }
            return false
        }
        return true
    }
    // Checks for string errors
    // -----------------------------------------------------------------
    func canOpenURL(_ string: String?) -> Bool {
        guard let urlString = string,
            let url = URL(string: urlString)
            else { return false }
        
        if !UIApplication.shared.canOpenURL(url) { return false }
        
        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/]|[:])((\\w|-)+))+"
        
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: string)
        
        //       let predicate2 = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx2])
        //        return predicate2.evaluate(with: string)
        //        let regEx2 = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)
        //        +([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
    }
    

    // These are the main functions where all the major HTTP tests happen.
    //Functions throw High and low Res alerts depending on URL flags
    // -----------------------------------------------------------------
    func getHighResURLResponse(urlPath : String, TypeofURL: String) {
        let url = URL(string: urlPath)!
        print(urlPath)
//        // Tried some hacks
//        if fileExists(url: url as NSURL) == false {
//            print("file dose not exist")
//        }
//        // Tried some hacks
//        tryPlayingURL(stream: url, TypeofURL: "High")

        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
			
            if let httpResponse = response as? HTTPURLResponse {
                let localizedResponse = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                print("Status Code : \(httpResponse.statusCode)  \(localizedResponse)")
                    self.highResHTTPCode = httpResponse.statusCode

                if httpResponse.statusCode >= 400
                {
                    let message : String =  String(httpResponse.statusCode) + " " + localizedResponse
                   print(message)
                        self.highResMessage = message
                        self.highResValidity = false
                        self.isHighResTaskCompleated = true
                        self.invalidateHighResTimer()
                    return
                }
                else {
                    let message : String = String(httpResponse.statusCode) + " " + localizedResponse
                    print(message)
                        self.highResMessage = message
                        self.highResValidity = true
                        self.isHighResTaskCompleated = true
                        self.invalidateHighResTimer()
                    return
                }
            }
            else {
                self.highResValidity = false
                self.isHighResTaskCompleated = true
                self.invalidateHighResTimer()
            }
        }

        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(runHigh), userInfo: nil, repeats: false)

        task.resume()

    }
    
    func getLowResURLResponse(urlPath : String, TypeofURL: String) {
        let url = URL(string: urlPath)!
        // Tried some hacks
//        if fileExists(url: url as NSURL) == false {
//            print("file dose not exist")
//        }
//        // Tried some hacks
//        tryPlayingURL(stream: url, TypeofURL: TypeofURL)
//
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            
            if let httpResponse = response as? HTTPURLResponse {
                let localizedResponse = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                print("Status Code : \(httpResponse.statusCode)  \(localizedResponse)")
                self.lowResHTTPCode = httpResponse.statusCode
                if httpResponse.statusCode >= 400
                {
                    let message : String =  String(httpResponse.statusCode) + " " + localizedResponse
                    print(message)
                        self.lowResMessage = message
                        self.lowResValidity = false
                        self.isLowResTaskCompleated = true
                    return
                }
                else {
                    let message : String = String(httpResponse.statusCode) + " " + localizedResponse
                    print(message)
                        self.lowResMessage = message
                        self.lowResValidity = true
                        self.isLowResTaskCompleated = true
                    return
                }
            }
            else {
                self.lowResValidity = false
                self.isLowResTaskCompleated = true
                self.invalidateHighResTimer()
            }
        }

        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(runLow), userInfo: nil, repeats: false)
        
        task.resume()
    }
    // Functions to invalidate timers
    // -----------------------------------------------------------------
    @objc func invalidateHighResTimer(){
        //      Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(invalidateHighTimer), userInfo: nil, repeats: false)
    }
    @objc func invalidateLowResTimer(){
        
        //      Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(invalidateLowTimer), userInfo: nil, repeats: false)
    }
    
    @objc func invalidateHighTimer(){
        print("highResTimer Invalidated")
        //       self.highResTimer?.invalidate()
    }
    @objc func invalidateLowTimer(){
        print("lowResTimer Invalidated")
        //       self.lowResTimer?.invalidate()
    }
    
    // Functions Runs after a delay of 1 sec
    // and throws High and low Res alerts depending on URL flags
    // -----------------------------------------------------------------
    @objc func runLow(){
        print("isLowResTaskCompleated == \(isLowResTaskCompleated)")
        if isLowResTaskCompleated == false {
            return
        }
        if self.lowResValidity == true{
            self.lowResImgStatus.image = UIImage(named: "tick")
        }
        else{
            self.lowResImgStatus.image = UIImage(named: "cross")
            
                AJAlertController.initialization().showAlertWithOkButton(title:"Low Res Status Code : ",aStrMessage: self.lowResMessage) { (index, title) in
                    print(index,title)
                    if index == 0 {
                    }
                }
        }
        
        if self.lowResValidity == true && self.highResValidity == true {
            self.OKbutton.isEnabled = true
        }
        else {
            self.OKbutton.isEnabled = false
        }
        if isLowResTaskCompleated == true {
            self.invalidateLowResTimer()
        }
    }
    
    @objc func runHigh(){
        print("isHighResTaskCompleated == \(isHighResTaskCompleated)")
        if isHighResTaskCompleated == false {
            return
        }
        if self.highResValidity == true{
            self.highResImgStatus.image = UIImage(named: "tick")
        }
        else{
            self.highResImgStatus.image = UIImage(named: "cross")
                AJAlertController.initialization().showAlertWithOkButton(title:"High Res Status Code : ",aStrMessage: self.highResMessage) { (index, title) in
                    print(index,title)
                    if index == 0 {
                    }
                }
        }
        
        if self.lowResValidity == true && self.highResValidity == true {
            self.OKbutton.isEnabled = true
        }
        else {
            self.OKbutton.isEnabled = false
        }
        if isHighResTaskCompleated == true {
            self.invalidateHighResTimer()
        }
    }

    // Tried some Hacks
    // -----------------------------------------------------------------
    func fileExists(url : NSURL!) -> Bool {
        
        let req = NSMutableURLRequest(url: url as URL)
        req.httpMethod = "HEAD"
        req.timeoutInterval = 1.0 // Adjust to your needs
        
        var response : URLResponse?
        do {
            try NSURLConnection.sendSynchronousRequest(req as URLRequest, returning: &response)
        }
        catch {
            print("fail")
        }
        return ((response as? HTTPURLResponse)?.statusCode ?? -1) == 200
    }

    func tryPlayingURL(stream: URL, TypeofURL : String){
        
        let item = AVPlayerItem(url: stream)
        let output = AVPlayerItemVideoOutput(outputSettings: nil)
        item.add(output)
        if TypeofURL == "High" {
            self.highResValidity = true
        }
        else {
            self.lowResValidity = true
        }
        playerItemObserver = item.observe(\.status) { [weak self] item, _ in
            guard item.status == .readyToPlay
            else  {
                    print("failed")
                    if TypeofURL == "High" {
                        self?.highResValidity = false
                        return
                    }
                    else {
                        self?.lowResValidity = false
                        return
                    }
                    return
            }
            self?.playerItemObserver = nil
        }
    }
// -----------------------------------------------------------------
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //
    //        if let identifier = segue.identifier {
    //            if identifier == "mainMenu" {
    //                if let viewController = segue.destination as? MenuViewController {
    //                    viewController.ipAddress_highres = urlHighResTextField.text!
    //                    viewController.ipAddress_lowres = urlLowResTextField.text!
    //                }
    //            }
    //        }
    //    }

}

// Helper functions For sanitizing the URLs
extension String {
    func replace(string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func sanitize() -> String {
        return self.replace(string: " ", replacement: "").localizedLowercase
    }
}
var vSpinner : UIView?
extension UIViewController {
    
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}
