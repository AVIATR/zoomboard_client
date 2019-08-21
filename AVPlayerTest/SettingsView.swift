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


class SettingsView: UIViewController,UITextFieldDelegate {
    
    struct streamStatus {
        var urlValid: Bool = false
        var streamExists: Bool = false
        var HTTPResponseReceived: Bool = false
        var statusImage: UIImageView
        var HTTPCode: Int
        var responseMsg: String
    }

//    @IBOutlet weak var urlHighResTextField: UITextField!
//    @IBOutlet weak var urlLowResTextField: UITextField!
    
    @IBOutlet weak var lowResImgStatus: UIImageView!
    @IBOutlet weak var highResImgStatus: UIImageView!
    
    let httpRequestTimeout = 5.0
    
    var lowResTimer : Timer?
    var highResTimer : Timer?
    
    @IBOutlet weak var highResTextField: UITextField!
    @IBOutlet weak var lowResTextField: UITextField!
    
    var streamInfo : [String: streamStatus] = [:]
    
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
    
    
    @IBOutlet weak var msgLabel: UILabel!
    
    weak var MenuViewContDelegate: MenuViewController?
    var throwAlert : Bool = false
    

    @IBOutlet weak var scrollViewOutlet: UIScrollView!
    @IBOutlet weak var OKbutton: UIButton!

    @IBOutlet weak var topRect: UILabel!
    @IBOutlet weak var topKeyboardLimit: UILabel!
    @IBOutlet weak var keyboardText: UILabel!
    private var playerItemObserver: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        streamInfo[highResTextField.accessibilityIdentifier!] = streamStatus(urlValid: false, streamExists: false, HTTPResponseReceived: false, statusImage: highResImgStatus, HTTPCode: 0, responseMsg: "")
        streamInfo[lowResTextField.accessibilityIdentifier!] = streamStatus(urlValid: false, streamExists: false, HTTPResponseReceived: false, statusImage: lowResImgStatus, HTTPCode: 0, responseMsg: "")
        
        OKbutton.setTitleColor(.gray, for: .disabled)
        
        highResValidity = true
        lowResValidity = true
        
        scrollViewOutlet.showsVerticalScrollIndicator = false
        scrollViewOutlet.showsHorizontalScrollIndicator = false

        scrollViewOutlet.isPagingEnabled = false
        scrollViewOutlet.isScrollEnabled = false

        highResTextField.text = highResURL
        lowResTextField.text = lowResURL

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
        highResTextField.text = highResDef
        lowResTextField.text = lowResDef
        highResTextEntered(sender)
        lowResTextEntered(sender)
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
        if sender == lowResTextField {
            scrollViewOutlet.scrollRectToVisible(keyboardText.frame, animated: true)
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

        if lowResTextField.text?.isEmpty == false && highResTextField.text?.isEmpty == false{

            lowResTextField.text = lowResTextField.text?.sanitize()
            highResTextField.text = highResTextField.text?.sanitize()
            
            if canOpenURL(lowResTextField.text)==false{
                AJAlertController.initialization().showAlertWithOkButton(title:"Settings",aStrMessage: "Please enter a valid Low Resolution URL") { (index, title) in
                    print(index,title)
                    if index == 0 {
                    }
                }
                return
            }
            if canOpenURL(highResTextField.text)==false{
                AJAlertController.initialization().showAlertWithOkButton(title:"Settings",aStrMessage: "Please enter a valid High Resolution URL") { (index, title) in
                    print(index,title)
                    if index == 0 {
                    }
                }
                return
            }

            MenuViewContDelegate?.ipAddress_highres = highResTextField.text!
            MenuViewContDelegate?.ipAddress_lowres = highResTextField.text!
            dismiss(animated: true, completion: nil)
        }
        else{
            if highResTextField.text?.isEmpty == true{
                lowResTextField.backgroundColor = UIColor.red
            }
            if highResTextField.text?.isEmpty == true{
                highResTextField.backgroundColor = UIColor.red
            }
        }
    }


    // Calls just after text is entered in High and Low Res URLs
    // -----------------------------------------------------------------
    @IBAction func highResTextEntered(_ sender: Any) {
        
        scrollViewOutlet.scrollRectToVisible(topRect.frame, animated: true)
        highResImgStatus.image = UIImage(named: "sync")
        highResImgStatus.isHidden = false
        highResValidity = true
        isHighResTaskCompleated =  false
     //   highResTimer?.fire()
        self.validateHighResURL(sender)
    }
    
    @IBAction func urlEditDidEnd(_ sender: UITextField) {
        scrollViewOutlet.scrollRectToVisible(topRect.frame, animated: true)
        let streamID = sender.accessibilityIdentifier
        streamInfo[streamID!]!.statusImage.image = UIImage(named: "sync")
        streamInfo[streamID!]!.statusImage.isHidden = false
        streamInfo[streamID!]!.urlValid = false
        streamInfo[streamID!]!.HTTPResponseReceived = false
        streamInfo[streamID!]!.streamExists = false
        self.validateURL(sender: sender)
    }
    
    func validateURL(sender: UITextField){
        //first check if URL is valid
        let streamID = sender.accessibilityIdentifier
        
        // we have a string to validate
        if sender.text?.isEmpty == false{
            sender.text = sender.text?.sanitize()
            if canOpenURL(sender.text) == false{ // the url is incorrect
                
                streamInfo[streamID!]?.statusImage.image = UIImage(named: "cross")
                streamInfo[streamID!]?.urlValid = false
                //            streamInfo[streamID!]?.streamExists = false
                //            streamInfo[streamID!]?.HTTPResponseReceived = false
                
                return
            }
        }
        else{
            streamInfo[streamID!]!.statusImage.image = UIImage(named: "cross")
            OKbutton.isEnabled = false
        }
        
    }
    
    
    @IBAction func lowResTextEntered(_ sender: Any) {
        
        scrollViewOutlet.scrollRectToVisible(topRect.frame, animated: true)
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
        msgLabel.isHidden = false
        if highResTextField.text?.isEmpty == false{
            highResTextField.text = highResTextField.text?.sanitize()
            if throwAlerts(URL : highResTextField.text!, TypeofURL: "High") == false{
                isHighResTaskCompleated = true
                invalidateHighResTimer()
                return
            }
            getHighResURLResponse(urlPath: highResTextField.text!, TypeofURL: "High")
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
        msgLabel.isHidden = false
        if lowResTextField.text?.isEmpty == false {
            lowResTextField.text = highResTextField.text?.sanitize()
            if throwAlerts(URL : lowResTextField.text!, TypeofURL: "Low") == false {
                isLowResTaskCompleated =  true
                invalidateLowResTimer()
                return
            }
            getLowResURLResponse(urlPath: lowResTextField.text!, TypeofURL: "Low")
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
    
//    func throwAlerts(sender: UITextField)-> Bool{
//        let streamID = sender.accessibilityIdentifier
//        if canOpenURL(sender.text)==false{
//
//            streamInfo[streamID!]?.statusImage.image = UIImage(named: "cross")
//            streamInfo[streamID!]?.urlValid = false
//            streamInfo[streamID!]?.streamExists = false
//            streamInfo[streamID!]?.HTTPResponseReceived = false
//            // TODO: stop time? I am not sure
//
//            // what is this?
////            AJAlertController.initialization().showAlertWithOkButton(title:"Settings",aStrMessage: "Please enter a valid \(TypeofURL) Resolution URL") { (index, title) in
////                print(index,title)
////                if index == 0 {
////                }
////            }
//            return false
//        }
//        return true
//    }
    
    
    
    
    
    
//    func throwAlerts(URL : String,TypeofURL : String)-> Bool{
//        if canOpenURL(URL)==false{
//            if TypeofURL == "High"{
//                highResImgStatus.image = UIImage(named: "cross")
//                highResValidity = false
//                isHighResTaskCompleated = true
//                invalidateHighResTimer()
//            }
//            else {
//                lowResValidity = false
//                lowResImgStatus.image = UIImage(named: "cross")
//                isLowResTaskCompleated = true
//                invalidateLowResTimer()
//            }
//            AJAlertController.initialization().showAlertWithOkButton(title:"Settings",aStrMessage: "Please enter a valid \(TypeofURL) Resolution URL") { (index, title) in
//                print(index,title)
//                if index == 0 {
//                }
//            }
//            return false
//        }
//        return true
//    }
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

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = httpRequestTimeout
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
                self.highResMessage = "Error"
                self.highResValidity = false
                self.isHighResTaskCompleated = true
                self.invalidateHighResTimer()
            }
        }

        highResTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runHigh), userInfo: nil, repeats: true)

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
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = httpRequestTimeout
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
                self.lowResMessage = "Error"
                self.lowResValidity = false
                self.isLowResTaskCompleated = true
                self.invalidateHighResTimer()
            }
        }

        lowResTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runLow), userInfo: nil, repeats: true)
        
        task.resume()
    }
    // Functions to invalidate timers
    // -----------------------------------------------------------------
    @objc func invalidateHighResTimer(){
  //      highResTimer?.invalidate()
        //      Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(invalidateHighTimer), userInfo: nil, repeats: false)
    }
    @objc func invalidateLowResTimer(){
  //      lowResTimer?.invalidate()
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
            isLowResTaskCompleated = false
            lowResTimer?.invalidate()
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
            isHighResTaskCompleated = false
            highResTimer?.invalidate()
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
