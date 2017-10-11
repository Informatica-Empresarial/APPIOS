//
//  DKHRateServiceViewController.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 6/10/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit
import HCSStarRatingView
import SVProgressHUD

class DKHRateServiceViewController: DKHBaseViewController {
    
    @IBOutlet weak var startRating: HCSStarRatingView!
    @IBOutlet weak var rateView: UIView?
    
    @IBOutlet weak var firstLeftButton: UIButton!
    @IBOutlet weak var secondLeftButton: UIButton!
    
    @IBOutlet weak var firstRightButton: UIButton!
    @IBOutlet weak var secondRightButton: UIButton!
    
    @IBOutlet weak var starLabelDescription: UILabel!
    @IBOutlet weak var workerImageView: UIImageView!
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet var rateViewContraint: NSLayoutConstraint!
    
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet var commentConstraint: NSLayoutConstraint!
    
    
    var appointment:DKHServiceAppointment?
    
    var rateClosure:((_ appointment:DKHServiceAppointment?)->())?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        firstLeftButton.setTitleColor(UIColor.programColor(), for: .selected)
        secondLeftButton.setTitleColor(UIColor.programColor(), for: .selected)
        firstRightButton.setTitleColor(UIColor.programColor(), for: .selected)
        secondRightButton.setTitleColor(UIColor.programColor(), for: .selected)
        
        firstLeftButton.setTitleColor(UIColor.sosColor(), for: .normal)
        secondLeftButton.setTitleColor(UIColor.sosColor(), for: .normal)
        firstRightButton.setTitleColor(UIColor.sosColor(), for: .normal)
        secondRightButton.setTitleColor(UIColor.sosColor(), for: .normal)
        
        
        contentTextView?.placeholder        = NSLocalizedString("additional_comment", comment: "")
        //contentTextView?.placeholderColor   = UIColor(css: "#C8C8C8")
        setupHomeButton()
        changeStarValue(self)
        
        guard let appointment = appointment, let worker = appointment.worker, let url = URL(string:worker.imageUrl) else {
            workerImageView.image = UIImage(named:"avatar")
            return
        }
        workerImageView.af_setImage(withURL: url, placeholderImage: UIImage(named:"avatar"))
    }
    
    func cancelRate() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func doneAction(_ sender: Any) {
        rateAppointment()
    }
    
    @IBAction func selectFeedBackAction(_ sender: UIButton) {
        
        if !sender.isSelected {
            sender.isSelected   = true
            sender.borderColor  = UIColor.programColor()
        }else {
            sender.isSelected = false
            sender.borderColor  = UIColor.sosColor()
        }
    }
    
    @IBAction func changeStarValue(_ sender: Any) {
        let localizedMessage = "star_\(Int(startRating.value))_description"
        starLabelDescription.text = NSLocalizedString(localizedMessage, comment: "")
        
        if startRating.value == 5.0 {
            rateView?.isHidden          = true
            commentConstraint.isActive  = false
            rateViewContraint.isActive  = false
            //rateView?.removeFromSuperview()
        }else {
            rateViewContraint.isActive  = true
            commentConstraint.isActive  = true
            rateView?.isHidden          = false
        }
    }
    
    
     func rateAppointment() {
        
        var comments = ""
        if firstLeftButton.isSelected {
            if comments.isEmpty {
                comments += NSLocalizedString("professionalism", comment: "")
            }
        }
        
        if secondLeftButton.isSelected {
            if comments.isEmpty {
                comments += NSLocalizedString("technique", comment: "")
            }else {
                comments += ", " + NSLocalizedString("technique", comment: "")
            }
        }
        
        if firstRightButton.isSelected {
            if comments.isEmpty {
                comments += NSLocalizedString("agility", comment: "")
            }else {
                comments += "," + NSLocalizedString("agility", comment: "")
            }
        }
        
        if secondRightButton.isSelected {
            if comments.isEmpty {
                comments += NSLocalizedString("amiability", comment: "")
            }else {
                comments += "," + NSLocalizedString("amiability", comment: "")
            }
        }
        
        comments += " " + contentTextView.text
        
        SVProgressHUD.show()
        
        guard  let appointment = appointment else {
            return
        }
        DKHServiceAppointment.rateAppointment(endPoint: DKHEndPoint.rateAppointment(appointmentUuid: appointment.uuid, rate: Int(startRating.value), comments: comments)) { (success, appointment) in
            print(success)
            SVProgressHUD.dismiss()
            if success {
                self.appointment = appointment
                self.dismiss(animated: true, completion: nil)
                self.rateClosure?(appointment)
            }else {
                self.rateClosure?(nil)
            }
        }
        
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
