//
//  DKHServicesTableViewController.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 4/20/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit
import CoreLocation
import SVProgressHUD


class DKHServicesViewController: DKHBaseViewController,UITableViewDataSource,UITableViewDelegate {
    
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet var checkout: UIView!
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var showErroMessage = false
    var servicesSummary:DKHServiceSummary!
    var services = [DKHService]()
    var userLocation:CLLocationCoordinate2D?
    var serviceCount = [String:Double]()
    var selectedCity:DKHCity?
    
    override func viewDidLoad() {
        registerCell()
        tableView.dataSource    = self
        tableView.delegate      = self
        super.viewDidLoad()
        getServices()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkServiceCount()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        tableView.tableFooterView       = UIView()
        tableView.estimatedRowHeight    = 100
        title                           = "LA FEMME"
        tableView.rowHeight             = UITableViewAutomaticDimension
        priceLabel.text                 = ""
        
    }
    
    func registerCell() {
        tableView.register(UINib(nibName:"DKHSelectServiceTableViewCell",bundle:nil), forCellReuseIdentifier: "DKHSelectServiceTableViewCell")
        tableView.register(UINib(nibName:"DKHEmptyResultsTableViewCell", bundle: nil), forCellReuseIdentifier: "DKHEmptyResultsTableViewCell")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard services.count != 0 || !showErroMessage else {
            return 1
        }
        return services.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard services.count != 0 || !showErroMessage else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DKHEmptyResultsTableViewCell", for: indexPath) as! DKHEmptyResultsTableViewCell
            cell.setupCellForServices()
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DKHSelectServiceTableViewCell", for: indexPath) as! DKHSelectServiceTableViewCell
        
        let service = services[indexPath.row]
        cell.setupCell(service: service)
        
        cell.valueChangedOnService = { count in
            self.servicesSummary.currency    = service.currency
            self.serviceCount.updateValue(count, forKey: service.uuid)
            self.calculatePrice()
        }
        
        return cell
    }
    
    
    @IBAction func continueButtonAction(_ sender: Any) {
        servicesSummary.services    = serviceCount
        
        if !servicesSummary.sosSearch {
            let selectAddres = DKHNavigation.selectAddress()
            selectAddres.selectedCity   = selectedCity
            selectAddres.serviceSummary = servicesSummary
            self.navigationController?.pushViewController(selectAddres, animated: true)
        }else {
            getSosAvailability()
        }
    }
    
    func getSosAvailability() {
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
        
        DKHAvailability.getAvailability(endPoint: DKHEndPoint.getSosAvailability(workerUuid: nil, coordinates: servicesSummary.coordinates, services: servicesSummary.services), clousure: { (availability) in
        
            guard let worker = availability.workers.first, let firstDate = worker.dates.first else {
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("no_workers_availables", comment: ""))
                return
            }
            let selectWorker = DKHNavigation.summaryViewCotroller()
            self.servicesSummary.worker         = worker
            self.servicesSummary.selectedTime   = firstDate.date.UTCToLocal()
            selectWorker.serviceSummary         = self.servicesSummary
            
            self.navigationController?.pushViewController(selectWorker, animated: true)
            
        }, errorClosure: {error in
            guard let error = error else {
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("no_workers_availables", comment: ""))
                return
            }
            SVProgressHUD.showInfo(withStatus: error)
        })
    }


    
    private func getServices() {
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
        
        DKHService.all(endPoint: DKHEndPoint.getServices(location: userLocation, currency: "COP", city: "Medellín")) { (services) in
            guard let services = services else {
                SVProgressHUD.dismiss()
                return
            }
            
            self.services = services
            self.showErroMessage = true
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
        }
    }
    
    private func calculatePrice() {
        var total       = 0.0
        var currency    = ""
        
        for (serviceUuid,ammount) in serviceCount {
            if ammount == 0 {
                serviceCount.removeValue(forKey: serviceUuid)
            }
            guard  let service = self.services.filter({$0.uuid == serviceUuid}).first else {
                return
            }
            currency    = service.currency
            guard let priceDouble = Double(service.price) else {
                return
            }
            
            total += priceDouble * ammount
        }
        
        
        let numberFormatter             = NumberFormatter()
        numberFormatter.numberStyle     = .currency
        let stringValue                 = numberFormatter.string(from: NSNumber(value: total))
        self.priceLabel.text            = stringValue
        checkServiceCount()
    }
    
    private func checkServiceCount() {
        continueButton.isEnabled    = serviceCount.count != 0
    }
    
    private func registerDevice() {
        guard let token = UserDefaults.standard.object(forKey: "deviceToken") as? String  else {
            return
        }
        DKHUser.registerDevice(endPoint: .registerDevice(deviceToken: token)) { (success) in
            print(success)
        }
    }
    
    
}
