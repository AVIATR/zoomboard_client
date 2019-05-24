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
            if let presenter = presentingViewController as? MenuViewController {
                presenter.ipAddress_highres = urlHighResTextField.text ?? "127.0.0.1"
                presenter.ipAddress_lowres = urlLowResTextField.text ?? "127.0.0.1"
            }
            dismiss(animated: true, completion: nil)
            delegate?.removeBlurredBackgroundView()
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
    override func viewDidLayoutSubviews() {
//        view.backgroundColor = UIColor.clear
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
