//
//  DKHMyServicesTableViewController.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 5/14/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit
import SVProgressHUD
import RealmSwift

class DKHMyServicesTableViewController: DKHBaseTableViewController {
    
    @IBOutlet var filterServicesView: UIView!
    @IBOutlet weak var filterServices: UISegmentedControl!
    var appointments = [DKHServiceAppointment]()
    var filteredAppointments = [DKHServiceAppointment]()
    
    var showError = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAppointments()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title                           = NSLocalizedString("my_services_title", comment: "")
        tableView.tableFooterView       = UIView()
        tableView.tableHeaderView       = filterServicesView
        filterServices.setTitle(NSLocalizedString("current_active_services", comment: ""), forSegmentAt: 0)
        filterServices.setTitle(NSLocalizedString("history_services", comment: ""), forSegmentAt: 1)
        addPullToRefesh()
    }
    
    override func registerCell() {
        super.registerCell()
        tableView.register(UINib(nibName:"DKHMyAppointmentsTableViewCell",bundle:nil), forCellReuseIdentifier: "DKHMyAppointmentsTableViewCell")
    }
    
    override func refesh() {
        getAppointments()
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard filteredAppointments.count != 0 else {
            if showError {
                return 1
            }else {
                return 0
            }
        }
        return filteredAppointments.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard filteredAppointments.count != 0 else {
            let  cell = tableView.dequeueReusableCell(withIdentifier: "DKHEmptyResultsTableViewCell", for: indexPath) as! DKHEmptyResultsTableViewCell
            
            cell.setupCellForMyServices(localizedString: filterServices.selectedSegmentIndex == 0 ? "pending_services":"completed_services")
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DKHMyAppointmentsTableViewCell", for: indexPath) as! DKHMyAppointmentsTableViewCell
        
        let currentAppointment = filteredAppointments[indexPath.row]
        var leftViewColor:UIColor?
        leftViewColor = indexPath.row % 2 == 0 ? UIColor(hex:"#b7b6e0"):UIColor(hex:"#a7a6cf")
        cell.setupCell(startDate: currentAppointment.startDate, endDate: currentAppointment.endDate,leftViewColor: leftViewColor)
        
        return cell
    }
    
    @IBAction func changeFilterAction(_ sender: Any?) {
        
        if filterServices.selectedSegmentIndex == 0 {
            filteredAppointments =  appointments.filter({$0.status == AppointmentStatus.scheduled.rawValue || $0.appointmentStatus == .inProgress})
        }else {
            filteredAppointments =  appointments.filter({$0.status == AppointmentStatus.delivered.rawValue})
        }
        
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("my_services_title", comment: "")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailService = DKHNavigation.summaryViewCotroller()
        detailService.appointment   = filteredAppointments[indexPath.row]
        detailService.cancelAppointmentClosure = {
            Realm.update(updateClosure: { (realm) in
                realm.delete(self.filteredAppointments[indexPath.row])
            })
        }
        self.navigationController?.pushViewController(detailService, animated: true)
        
    }
    
    
    private func getAppointments() {
        
        SVProgressHUD.show()
        DKHServiceAppointment.all(endPoint: .appointments(workerUuid: "")) { (appointments) in
            
            self.refreshControl?.endRefreshing()
            guard let newAppointments =  appointments else {
                self.showError = true
                
                return
            }
            
            self.appointments   = newAppointments.sorted(by: { (lhsData, rhsData) -> Bool in
                return rhsData.startDate > lhsData.startDate
            })
            self.showError = true
            self.changeFilterAction(nil)
        }
    }
}
