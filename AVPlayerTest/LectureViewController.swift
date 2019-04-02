//
//  LectureViewController.swift
//  AVPlayerTest
//
//  Created by PARAG VIJAYRAJ PATHAK on 4/1/19.
//  Copyright © 2019 SKERI. All rights reserved.
//

import UIKit

class LectureViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    var streamURL : URL = URL(string:"https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")!

    var lectureName : String = "lecture 1"
    
    @IBOutlet weak var textFieldURL: UITextField!
    @IBOutlet weak var textFieldLectureName: UITextField!
    
    @IBAction func buttonTapAddURL(_ sender: Any) {
        if let text = textFieldURL.text {
            if text == "" {
                return
            }
            streamURL = URL(string: textFieldURL.text ?? "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")!
            textFieldURL.resignFirstResponder()
        }
    }
    
    @IBAction func buttonTapAddLectureName(_ sender: Any) {
        if let text = textFieldLectureName.text {
            if text == "" {
                return
            }
            lectureName =   textFieldLectureName.text!
            textFieldLectureName.resignFirstResponder()
        }
    }
    @IBAction func startVideoViewContoller(_ sender: Any) {
        performSegue(withIdentifier: "ShowVideo", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let viewController = segue.destination as? ViewController {
            viewController.streamURL = streamURL
            viewController.lectureName = lectureName
        }
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
