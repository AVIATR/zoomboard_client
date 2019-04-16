//
//  MenuViewController.swift
//  AVPlayerTest
//
//  Created by PARAG VIJAYRAJ PATHAK on 4/1/19.
//  Copyright © 2019 SKERI. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        if (UserDefaults.standard.object(forKey: "MostRecentLecture") as! String?) == nil{
            return
        }

        performSegue(withIdentifier: "continueLectureSegue2", sender: nil)
        
    }
    @IBAction func newLecture(_ sender: Any) {
        performSegue(withIdentifier: "ShowLectureView", sender: nil)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let viewController = segue.destination as? ViewController {
            if let text = UserDefaults.standard.object(forKey: "MostRecentLecture") as! String?{
                viewController.lectureName = text
            }
            else{
                return
            }
            viewController.continueLecture = false
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
