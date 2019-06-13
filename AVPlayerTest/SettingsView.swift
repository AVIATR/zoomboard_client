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
    var highResDef : String = "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"
    var lowResDef : String = "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8"

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
                AJAlertController.initialization().showAlertWithOkButton(aStrMessage: "Please enter a valid Low Resolution URL") { (index, title) in
                    
                    print(index,title)
                    if index == 0 {
                        
                    }
                }

                return
            }
            if canOpenURL(urlHighResTextField.text)==false{
                AJAlertController.initialization().showAlertWithOkButton(aStrMessage: "Please enter a valid High Resolution URL") { (index, title) in

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
        
        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let regEx2 = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        let predicate2 = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx2])
        
        return predicate.evaluate(with: string)
//        return predicate2.evaluate(with: string)
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
