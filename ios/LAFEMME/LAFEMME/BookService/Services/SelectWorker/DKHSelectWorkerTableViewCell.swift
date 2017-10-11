//
//  DKHSelectWorkerTableViewCell.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 5/3/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit

class DKHSelectWorkerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var workerImageView: UIImageView?
    @IBOutlet weak var workerDescription: UILabel!
    @IBOutlet weak var workerName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func setupCell(worker:DKHWorker) {
        
        workerName.text  = worker.firstname + " " + worker.lastname
        workerDescription.text  = worker.userDescripton
        guard let url = URL(string:worker.imageUrl) else {
            return
        }
        workerImageView?.af_setImage(withURL: url, placeholderImage: UIImage(named:"avatar"))
    }
    
    func setupCellForSummary(worker:DKHWorker?,user:DKHCustomer?) {

        if let worker = worker {
            workerName.text         = worker.firstname + " " + worker.lastname
            workerDescription.text  = worker.phoneNumber
            workerImageView?.removeFromSuperview()
        }
        if let user = user {
            workerName.text         = user.firstname + " " + user.lastname
            workerDescription.text  = user.phoneNumber
            workerImageView?.removeFromSuperview()
        }
        
    }
    
}
