//
//  DKHShowWorkerViewController.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 5/28/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit

class DKHShowWorkerViewController: DKHBaseViewController {
    var serviceSummary:DKHServiceSummary!
    
    @IBOutlet weak var workerImageView: UIImageView!
    @IBOutlet weak var workerInfo: UILabel!
    @IBOutlet weak var workerPhone: UILabel!
    var dissmissClosure:(()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        self.view.backgroundColor                 = UIColor(hex: "#d1d0ed",alpha:0.2)
        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: "Cel:")
        attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.grayLigthColor(), range: NSMakeRange(0, attrString.length))
        
        let descString: NSMutableAttributedString = NSMutableAttributedString(string: serviceSummary.worker.phoneNumber)
        descString.addAttribute(NSForegroundColorAttributeName, value: UIColor.programColor(), range: NSMakeRange(0, descString.length))
        attrString.append(descString)
        
        workerPhone.attributedText   = attrString
        
        workerInfo.text             = serviceSummary.worker.firstname + NSLocalizedString("show_worker_sub_title", comment: "")
        
        guard let url = URL(string:serviceSummary.worker.imageUrl) else {
            return
        }
        workerImageView.af_setImage(withURL: url, placeholderImage: UIImage(named:"avatar"))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func aceptAction(_ sender: Any) {
        dissmissClosure?()
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
