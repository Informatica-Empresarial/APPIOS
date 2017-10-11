//
//  DKHSecondPageViewController.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 4/20/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit

class DKHSecondPageViewController: UIViewController {
    
    @IBOutlet weak var pageButton: UIButton!
    @IBOutlet weak var pageLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pageButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
