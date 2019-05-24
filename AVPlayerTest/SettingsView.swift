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
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.removeBlurredBackgroundView()
    }
    
    @IBAction func editingStarted(_ sender: UITextField) {
        sender.backgroundColor = UIColor.white
    }
    
    
    // TODO: sanitaze input ip address
    @IBAction func acceptChanges(_ sender: Any) {
        
        if urlLowResTextField.text?.isEmpty == false && urlHighResTextField.text?.isEmpty == false{
            performSegue(withIdentifier: "mainMenu", sender: nil)
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
}
