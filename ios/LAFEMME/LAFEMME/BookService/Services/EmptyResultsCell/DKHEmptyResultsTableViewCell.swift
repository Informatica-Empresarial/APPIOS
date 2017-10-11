//
//  DKHEmptyResultsTableViewCell.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 5/14/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit

class DKHEmptyResultsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel?
    
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCellForWorkers() {
        detailLabel.text    = NSLocalizedString("no_workers_availables", comment: "")
        
    }
    
    func setupCellForAvailability() {
        
        detailLabel.text    = NSLocalizedString("no_availability", comment: "")
        
    }
    
    
    func setupCellForServices() {
        detailLabel.text    = NSLocalizedString("no_services_available", comment: "")
    }
    
    func setupCellForMyServices(localizedString:String) {
        titleLabel?.removeFromSuperview()
        detailLabel.text    = NSLocalizedString(localizedString, comment: "")
    }
    
}
