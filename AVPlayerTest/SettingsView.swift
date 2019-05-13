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
    var ipAddress : String = ""
    
    @IBOutlet weak var ipAddressTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        ipAddressTextField.text = ipAddress
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.removeBlurredBackgroundView()
        
        
    }
    
    // TODO: sanitaze input ip address
    @IBAction func acceptChanges(_ sender: Any) {
        if let presenter = presentingViewController as? MenuViewController {
            presenter.ipAddress = ipAddressTextField.text ?? "127.0.0.1"
        }
        dismiss(animated: true, completion: nil)
        delegate?.removeBlurredBackgroundView()
    }
    override func viewDidLayoutSubviews() {
        view.backgroundColor = UIColor.clear
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
