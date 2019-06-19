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

    var highResURL : String = ""
    var lowResURL : String = ""
    
    @IBOutlet weak var urlHighResTextField: UITextField!
    @IBOutlet weak var urlLowResTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        urlHighResTextField.text = highResURL
        urlLowResTextField.text = lowResURL
        // Do any additional setup after loading the view.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func resetPressed(_ sender: Any) {
        urlHighResTextField.text = highResDef
        urlLowResTextField.text = lowResDef
    }
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
  //      delegate?.removeBlurredBackgroundView()
    }
    
    @IBAction func editingStarted(_ sender: UITextField) {
        sender.backgroundColor = UIColor.white
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
    
    @IBAction func validateURL(_ sender: Any) {
        
        if urlHighResTextField.text?.isEmpty == false{
            
            
            urlHighResTextField.text = urlHighResTextField.text?.sanitize()
            
            if canOpenURL(urlHighResTextField.text)==false{
                AJAlertController.initialization().showAlertWithOkButton(title:"Settings",aStrMessage: "Please enter a valid High Resolution URL") { (index, title) in
                    
                    print(index,title)
                    if index == 0 {
                    }
                }
                
                return
            }
            getURLResponse(urlPath: urlHighResTextField.text!)
        }

    }
    
    @IBAction func validateLowRes(_ sender: Any) {
        if urlLowResTextField.text?.isEmpty == false {
            
            urlLowResTextField.text = urlLowResTextField.text?.sanitize()
            
            
            if canOpenURL(urlLowResTextField.text)==false{
                
                AJAlertController.initialization().showAlertWithOkButton(title:"Settings",aStrMessage: "Please enter a valid Low Resolution URL") { (index, title) in
                    
                    print(index,title)
                    if index == 0 {
                        
                    }
                }
                
                return
            }

            getURLResponse(urlPath: urlLowResTextField.text!)
           

        }
    }
    func getURLResponse(urlPath : String){
        self.showSpinner(onView: self.view)
        let url = URL(string: urlPath)!
        let request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            
            if let httpResponse = response as? HTTPURLResponse {
                let localizedResponse = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                print("Status Code : \(httpResponse.statusCode)  \(localizedResponse)")
 
                if httpResponse.statusCode >= 400
                {
                    let message : String =  String(httpResponse.statusCode) + " " + localizedResponse
                   print(message)
                    AJAlertController.initialization().showAlertWithOkButton(title:"Status Code : ",aStrMessage: message) { (index, title) in
                    self.removeSpinner()
                    print(index,title)
                    if index == 0 {
                        self.removeSpinner()
                    }
                    }
                    
                    }
                else {
                    let message : String = String(httpResponse.statusCode) + " " + localizedResponse
                    print(message)
                    
                    AJAlertController.initialization().showAlertWithOkButton(title:"Status Code : ",aStrMessage: message) { (index, title) in
                        self.removeSpinner()
                        print(index,title)
                        if index == 0 {
                            self.removeSpinner()
                            
                        }
                    }
                    

                }

                
                
                }
            
        }
        task.resume()
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
