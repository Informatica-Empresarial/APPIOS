//
//  DKHDetailTableViewCell.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 5/20/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit

class DKHDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCellForTotal(total:String) {
        
        guard let price = Double(total) else {
            return
        }
        
        let numberFormatter             = NumberFormatter()
        numberFormatter.numberStyle     = .currency
        
        let stringValue                 = numberFormatter.string(from: NSNumber(value: price))
        title.text                      = NSLocalizedString("summary_total", comment: "")
        value.text                      = stringValue
    }
    
    func setupCellForDate(startDate:Date,endDate:Date) {
        title.text  = NSLocalizedString("date_title", comment: "")
        value.text  = (startDate as NSDate).formattedDate(withFormat: "dd MMMM / hh:mm a") + " - " +  (endDate as NSDate).formattedDate(withFormat: "hh:mm a")
    }
    
    func setupCellForAddress(address:String) {
        title.text  = NSLocalizedString("address", comment: "")
        value.text  = address
    }
    
}
