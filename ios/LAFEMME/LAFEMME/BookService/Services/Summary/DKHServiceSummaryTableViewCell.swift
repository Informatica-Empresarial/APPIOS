//
//  DKHServiceSummaryTableViewCell.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 5/18/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit

class DKHServiceSummaryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var servicePrice: UILabel!
    @IBOutlet weak var serviceName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCell(appointment:DKHAppointment?) {
        guard let appointment = appointment, let service = appointment.service, let price = Double(appointment.price) else {
            return
        }
        let numberFormatter             = NumberFormatter()
        numberFormatter.numberStyle     = .currency
        
        if let stringValue              = numberFormatter.string(from: NSNumber(value: price)) {
            serviceName.text            = service.name + " (x\(appointment.count))" + "   " + stringValue
        }else {
            serviceName.text            = service.name + " (x\(appointment.count))"
        }
        
        
    }
    
}
