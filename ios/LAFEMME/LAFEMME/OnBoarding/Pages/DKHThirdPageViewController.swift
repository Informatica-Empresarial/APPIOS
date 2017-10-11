//
//  DKHThirdPageViewController.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 4/20/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit

class DKHThirdPageViewController: DKHBaseViewController {

    @IBOutlet weak var pageButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var pageLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func registerButtonAction(_ sender: Any) {
        let registerNavigation = DKHNavigation.registerNavigation()
        let registerViewController = registerNavigation.topViewController as! DKHRegisterViewController
        
        registerViewController.onBoardingClosure = {
            self.dismiss(animated: true, completion: nil)
        }
        self.present(registerNavigation, animated: true, completion: nil)
    }
    
    @IBAction func pageButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
