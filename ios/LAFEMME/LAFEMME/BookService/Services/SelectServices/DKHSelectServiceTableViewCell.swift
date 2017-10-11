//
//  DKHSelectServiceTableViewCell.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 4/25/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit
import AlamofireImage

class DKHSelectServiceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var serviceDescription: UILabel!
    @IBOutlet weak var serviceCounter: UILabel!
    @IBOutlet weak var serviceImageView: UIImageView!
    
    @IBOutlet weak var serviceDetail: UILabel!
    
    var valueChangedOnService:((_ count:Double)->())?
    var count = 0.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCell(service:DKHService) {
        serviceDescription.text = service.name 
        serviceDetail.text      = service.price + " " + service.currency
        
        guard let url = URL(string: service.imageUuid) else {
            return
        }
        serviceImageView.af_setImage(withURL: url)
    }
    
    //    @IBAction func addOrRemoveServices(_ sender: Any)
    //    {
    //        serviceCounter.text =  String(format: "%.0f", serviceAddOrRemove.value)
    //        valueChangedOnService?(serviceAddOrRemove.value)
    //
    //    }
    //
    
    @IBAction func addService(_ sender: UIButton) {
        count = count + 1
        serviceCounter.text =  String(format: "%.0f", count)
        valueChangedOnService?(count)
    }
    
    @IBAction func removeService(_ sender: UIButton) {
        
        if count > 0 {
            count = count - 1
            serviceCounter.text =  String(format: "%.0f", count)
            valueChangedOnService?(count)
        }
        
    }
    
}
