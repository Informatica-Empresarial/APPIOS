//
//  DKHMyAppointmentsTableViewCell.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 5/18/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit

class DKHMyAppointmentsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var services: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateLabelTitle: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(startDate:Date, endDate:Date, leftViewColor:UIColor?) {
        
        dateLabel.text  = (startDate as NSDate).formattedDate(withFormat: "dd MMMM yyyy")
        timeLabel.text  = (startDate as NSDate).formattedDate(withFormat: "hh:mm a") + " - " +  (endDate as NSDate).formattedDate(withFormat: "hh:mm a")
        leftView.backgroundColor    =   leftViewColor
        
        
    }
    
}
