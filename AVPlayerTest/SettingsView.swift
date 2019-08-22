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
        var urlValid: Bool = false              // did the url pass the syntax check?
        var streamExists: Bool = false          // did we get a positive response to the HTTP request?
        var HTTPResponseReceived: Bool = false  // have we received the HTTP response?
        var statusImage: UIImageView            // status image
        var HTTPCode: Int                       // response code
        var responseMsg: String                 // response message
        var requestTask: URLSessionDataTask     // task to send HTTP request to URL
        var responseCheckTimer: Timer
    }
    
    @IBOutlet weak var lowResImgStatus: UIImageView!
    @IBOutlet weak var highResImgStatus: UIImageView!
    
    let httpRequestTimeout = 5.0
    
//    var lowResTimer : Timer?
//    var highResTimer : Timer?
    
    @IBOutlet weak var highResTextField: UITextField!
    @IBOutlet weak var lowResTextField: UITextField!
    
    var streamInfo : [String: streamStatus] = [:]
    
    var highResDef : String = Movies.hRes()
    var lowResDef : String = Movies.lRes()
    
    
    var highResURL : String = ""
    var lowResURL : String = ""
//
//    var highResValidity: Bool = true
//    var lowResValidity : Bool = true
//
//    var isHighResTaskCompleated: Bool = true
//    var isLowResTaskCompleated: Bool = true
//
//    var highResMessage : String = ""
//    var lowResMessage : String = ""
//
//    var highResHTTPCode : Int = 0
//    var lowResHTTPCode : Int = 0
//
    
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

        streamInfo[highResTextField.accessibilityIdentifier!] = streamStatus(urlValid: false, streamExists: false,
                                                                             HTTPResponseReceived: false, statusImage: highResImgStatus, HTTPCode: 0, responseMsg: "", requestTask: URLSessionDataTask(), responseCheckTimer: Timer())
        streamInfo[lowResTextField.accessibilityIdentifier!] = streamStatus(urlValid: false, streamExists: false,
                                                                            HTTPResponseReceived: false, statusImage: lowResImgStatus, HTTPCode: 0, responseMsg: "", requestTask: URLSessionDataTask(), responseCheckTimer: Timer())
        
        OKbutton.setTitleColor(.gray, for: .disabled)

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
//        highResTextEntered(sender)
//        lowResTextEntered(sender)
//        isHighResTaskCompleated = true
//        isLowResTaskCompleated = true
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
//        isHighResTaskCompleated = true
//        isLowResTaskCompleated = true
//        invalidateLowResTimer()
//        invalidateHighResTimer()
        streamInfo[highResTextField.accessibilityIdentifier!]!.responseCheckTimer.invalidate()
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
        
        print("OK Pressed")
    }


    // Calls just after text is entered in High and Low Res URLs
    // -----------------------------------------------------------------
    @IBAction func urlEditDidEnd(_ sender: UITextField) {
        OKbutton.isEnabled = false
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
            // we have a url, is it valid and is it pointing to something?
            initURLRequest(sender: sender)
            if streamInfo[streamID!]?.urlValid == false{
                msgLabel.isHidden = true
                // TODO: alert user that the URL is not well formatted
                self.msgLabel.isHidden = true
                print("Error in URL")
            }
            else{
                print("URL is good, waiting for HTTP response...")
            }
        }
        else{ //string is empty
            streamInfo[streamID!]!.statusImage.image = UIImage(named: "cross")
            OKbutton.isEnabled = false
            // TODO: send a message about empty text box
            sender.backgroundColor = UIColor.red
        }
        
    }
    
    
    func initURLRequest(sender: UITextField){
        msgLabel.isHidden = false
        let streamID : String = sender.accessibilityIdentifier!
        streamInfo[streamID]?.urlValid = true
        if !isURLValid(sender.text){
//        guard let url = URL(string: sender.text!) else {
            print("Error: URL is incorrect")
            streamInfo[streamID]?.statusImage.image = UIImage(named: "cross")
            streamInfo[streamID]?.urlValid = false
            return
        }
        
        guard let url = URL(string: sender.text!) else {return }
        self.streamInfo[streamID]!.HTTPResponseReceived = false
        // set up an HTTP request
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = httpRequestTimeout
        streamInfo[streamID]!.requestTask = URLSession.shared.dataTask(with: request as URLRequest) {data, response, error in
            
            if let httpResponse = response as? HTTPURLResponse {
                let localizedResponse = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                print("Status Code : \(httpResponse.statusCode)  \(localizedResponse)")
                let message : String =  String(httpResponse.statusCode) + " " + localizedResponse
                print(message)
                self.streamInfo[streamID]!.HTTPCode = httpResponse.statusCode
                if httpResponse.statusCode >= 400
                {
                    self.streamInfo[streamID]!.responseMsg = message
                    self.streamInfo[streamID]!.streamExists = false
                    self.streamInfo[streamID]!.HTTPResponseReceived = true
                    return
                }
                else {
                    self.streamInfo[streamID]!.responseMsg = message
                    self.streamInfo[streamID]!.streamExists = true
                    self.streamInfo[streamID]!.HTTPResponseReceived = true
                    return
                }
            }
            else {
                self.streamInfo[streamID]!.responseMsg = "Undefined error in URL request."
                self.streamInfo[streamID]!.streamExists = false
                self.streamInfo[streamID]!.HTTPResponseReceived = true
            }
        }
        self.streamInfo[streamID]!.responseCheckTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkHTTPRequestStatus), userInfo: ["streamID": streamID], repeats: true)
        streamInfo[streamID]!.requestTask.resume()
       
    }
    
    @objc func checkHTTPRequestStatus(timer: Timer){
        let info = timer.userInfo as! [String: String]
        let streamID = String(info["streamID"]!)
        let stream : streamStatus = self.streamInfo[streamID]!
        // did we receive the response?
        if stream.HTTPResponseReceived{
            // 1) stop the timer
            stream.responseCheckTimer.invalidate()
            handleResponse(stream: stream)
        }
        else{
          return
        }
    }
    
    
    func handleResponse(stream: streamStatus){
        self.msgLabel.isHidden = true
        if stream.streamExists{
            stream.statusImage.image = UIImage(named: "tick")
            OKbutton.isEnabled = true
        }
        else{
            stream.statusImage.image = UIImage(named: "cross")
            //TODO: show error message
        }
    }
    
    
    func isURLValid(_ string: String?) -> Bool {
        guard let urlString = string,
            let url = URL(string: urlString)
            else { return false }
        
        if !UIApplication.shared.canOpenURL(url) { return false }
        
        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/]|[:])((\\w|-)+))+"
        
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: string)
    }

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
