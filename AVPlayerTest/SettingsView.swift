//
//  SettingView.swift
//  AVPlayerTest
//
//  Created by Giovanni Fusco on 5/12/19.
//  Copyright © 2019 SKERI. All rights reserved.
//

import UIKit

protocol ModalViewControllerDelegate: class {
    func removeBlurredBackgroundView()
}

class SettingsView: UIViewController {

    weak var delegate: ModalViewControllerDelegate?
    weak var delegate2: MenuViewController?
    var highResDef : String = Movies.hRes()
    var lowResDef : String = Movies.lRes()
    var code : Int = 0
    @IBOutlet weak var srollViewOutlet: UIScrollView!
    var highResURL : String = ""
    var lowResURL : String = ""
    
    @IBOutlet weak var highResImgStatus: UIImageView!
    @IBOutlet weak var lowResImgStatus: UIImageView!
    
    @IBOutlet weak var urlHighResTextField: UITextField!
    @IBOutlet weak var urlLowResTextField: UITextField!
    var highR: Bool = true
    var lowR: Bool = true
    var high: Bool {
        get{
            return highR
        }
        set(val) {
            highR = val
            if val == true && low == true
            {
                OKbutton.tintColor = UIColor.blue
            }
            else {
                    OKbutton.tintColor = UIColor.gray
                
            }
        }
    }
        var low : Bool {
        get{
        return lowR
        }
        set(val) {
            lowR = val
            if val == true && high == true{
            OKbutton.tintColor = UIColor.blue
        }
        else{
            OKbutton.tintColor = UIColor.gray
        }
        }
    }

    
    
    @IBOutlet weak var OKbutton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        high = true
        low = true
        
        srollViewOutlet.showsVerticalScrollIndicator = false
        srollViewOutlet.showsHorizontalScrollIndicator = false

        srollViewOutlet.isPagingEnabled = false
        srollViewOutlet.isScrollEnabled = false

        urlHighResTextField.text = highResURL
        urlLowResTextField.text = lowResURL
        // Do any additional setup after loading the view.
//        OKbutton.tintColor = UIColor.gray
        highResImgStatus.image = UIImage(named: "tick")
        lowResImgStatus.image = UIImage(named: "tick")
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func highResTextEntered(_ sender: Any) {
        srollViewOutlet.scrollRectToVisible(topRect.frame, animated: true)
        lowResImgStatus.image = UIImage(named: "sync")
        highR = false
        OKbutton.tintColor = UIColor.gray
        self.validateURL(sender)
    }
    
    @IBOutlet weak var topRect: UILabel!
    @IBAction func lowResTextEntered(_ sender: Any) {
        srollViewOutlet.scrollRectToVisible(topRect.frame, animated: true)
        lowR = false
        highResImgStatus.image = UIImage(named: "sync")
        OKbutton.tintColor = UIColor.gray
        self.validateLowRes(sender)
    }
    @IBAction func resetPressed(_ sender: Any) {
        highR = true
        lowR = true
        lowResImgStatus.image = UIImage(named: "tick")
        highResImgStatus.image = UIImage(named: "tick")
        urlHighResTextField.text = highResDef
        urlLowResTextField.text = lowResDef
    }
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
  //      delegate?.removeBlurredBackgroundView()
    }
    
    @IBOutlet weak var topKeyboardLimit: UILabel!
    @IBOutlet weak var keyboardText: UILabel!
    @IBAction func editingStarted(_ sender: UITextField) {
        sender.backgroundColor = UIColor.white
        if sender == urlLowResTextField {
            srollViewOutlet.scrollRectToVisible(keyboardText.frame, animated: true)
        }
    }
    
    
    // TODO: sanitaze input ip address
    @IBAction func acceptChanges(_ sender: Any) {


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

            delegate2?.ipAddress_highres = urlHighResTextField.text!
            delegate2?.ipAddress_lowres = urlLowResTextField.text!
            dismiss(animated: true, completion: nil)
  //          performSegue(withIdentifier: "mainMenu", sender: nil)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier {
            if identifier == "mainMenu" {
                if let viewController = segue.destination as? MenuViewController {
                    viewController.ipAddress_highres = urlHighResTextField.text!
                    viewController.ipAddress_lowres = urlLowResTextField.text!
                }
            }
        }
    }
    func canOpenURL(_ string: String?) -> Bool {
        guard let urlString = string,
            let url = URL(string: urlString)
            else { return false }
        
        if !UIApplication.shared.canOpenURL(url) { return false }
        
        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/]|[:])((\\w|-)+))+"
//        let regEx2 = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
 //       let predicate2 = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx2])
        return predicate.evaluate(with: string)
//        return predicate2.evaluate(with: string)
    }
    func throwAlerts(URL : String,TypeofURL : String)-> Bool{
        if canOpenURL(URL)==false{
            if TypeofURL == "High"{
           lowResImgStatus.image = UIImage(named: "cross")
                high = false
            }
            else {
                low = false

                highResImgStatus.image = UIImage(named: "cross")
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
    @IBAction func validateURL(_ sender: Any) {
        
        if urlHighResTextField.text?.isEmpty == false{
            urlHighResTextField.text = urlHighResTextField.text?.sanitize()
            if throwAlerts(URL : urlHighResTextField.text!, TypeofURL: "High") == false{
                //Blur ok button
   //             highResImgStatus.image = UIImage(named: "cross")
                return
            }
            getURLResponse(urlPath: urlHighResTextField.text!, TypeofURL: "High")
        }
    }
    
    @IBAction func validateLowRes(_ sender: Any) {
        if urlLowResTextField.text?.isEmpty == false {
            urlLowResTextField.text = urlLowResTextField.text?.sanitize()
            if throwAlerts(URL : urlLowResTextField.text!, TypeofURL: "Low") == false {
                //Blur ok button
      //          lowResImgStatus.image = UIImage(named: "cross")
                return
            }
            getURLResponse(urlPath: urlLowResTextField.text!, TypeofURL: "Low")
        }
    }
    var URLFlag : Bool = false
    func getURLResponse(urlPath : String, TypeofURL: String) {
//        self.showSpinner(onView: self.view)

        var valid : Bool = true
 
        let url = URL(string: urlPath)!
        let request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            
            if let httpResponse = response as? HTTPURLResponse {
                let localizedResponse = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                print("Status Code : \(httpResponse.statusCode)  \(localizedResponse)")
                self.code = httpResponse.statusCode
                if httpResponse.statusCode >= 400
                {
                    
                    let message : String =  String(httpResponse.statusCode) + " " + localizedResponse
                   print(message)
//                    AJAlertController.initialization().showAlertWithOkButton(title:"Status Code : ",aStrMessage: message) { (index, title) in
//  //                  self.removeSpinner()
//                    print(index,title)
//                    if index == 0 {
// //                       self.removeSpinner()
//                    }
//                    }
                    if TypeofURL == "High"{
//                        self.lowResImgStatus.image = UIImage(named: "cross")
                        self.high = false
                        self.URLFlag = true
                    }
                    else {
//                        self.highResImgStatus.image = UIImage(named: "cross")
                        self.low = false
                        self.URLFlag = true

                    }
                    
                    }
                else {
                    let message : String = String(httpResponse.statusCode) + " " + localizedResponse
                    print(message)
//                    AJAlertController.initialization().showAlertWithOkButton(title:"Status Code : ",aStrMessage: message) { (index, title) in
//     //                   self.removeSpinner()
//                        print(index,title)
//                        if index == 0 {
//      //                      self.removeSpinner()
//                        }
//                    }
                    if TypeofURL == "Low" {
 //                       self.highResImgStatus.image = UIImage(named: "tick")
                        self.low = true
                        self.URLFlag = true
                    }
                    else {
                        self.high = true
                        self.URLFlag = true
 //                       self.lowResImgStatus.image = UIImage(named: "tick")
                    }
                }
                }
        }
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(run), userInfo: nil, repeats: false)
        task.resume()
        
    }
    @objc func run(){
        print("timer function ran  URLflag = \(self.URLFlag)")
        if self.URLFlag == true{
            if self.low == true{
                self.highResImgStatus.image = UIImage(named: "tick")
            }
            else{
                self.highResImgStatus.image = UIImage(named: "cross")
            }
            if self.high == true{
                self.lowResImgStatus.image = UIImage(named: "tick")
            }
            else{
                self.lowResImgStatus.image = UIImage(named: "cross")
            }
        }
    }

}

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
