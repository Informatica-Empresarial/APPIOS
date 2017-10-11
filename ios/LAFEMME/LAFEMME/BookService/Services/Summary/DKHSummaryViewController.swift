//
//  DKHSummaryViewController.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 5/14/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit
import SVProgressHUD
import UserNotifications
import CoreLocation

class DKHSummaryViewController: DKHBaseViewController, UITableViewDelegate,UITableViewDataSource {
    var serviceSummary:DKHServiceSummary!
    
    @IBOutlet weak var bookView: UIView?
    var appointment:DKHServiceAppointment?
    @IBOutlet weak var cancelButton: UIButton?
    @IBOutlet weak var bookButton: UIButton?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel?
    
    var cancelAppointmentClosure:(()->())?
    var canCancelAppointment = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        tableView.delegate      = self
        tableView.dataSource    = self
        getAppointment()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title   = "LA FEMME"
        tableView.estimatedRowHeight    = 40
        tableView.rowHeight             = UITableViewAutomaticDimension
        tableView.tableFooterView       = UIView()
        configureViewBasedOnAppointment()
        
    }
    
    func registerCells() {
        
        tableView.register(UINib(nibName:"DKHServiceSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "DKHServiceSummaryTableViewCell")
        tableView.register(UINib(nibName:"DKHDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "DKHDetailTableViewCell")
        tableView.register(UINib(nibName:"DKHSelectWorkerTableViewCell",bundle:nil), forCellReuseIdentifier: "DKHSelectWorkerTableViewCell")
        tableView.register(UINib(nibName:"DKHEmptyResultsTableViewCell",bundle:nil), forCellReuseIdentifier: "DKHEmptyResultsTableViewCell")
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let appointment = appointment else {
            return 0
        }
        if section == 0 {
            return appointment.appointment.count
        }else {
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let appointment = appointment else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DKHEmptyResultsTableViewCell", for: indexPath) as! DKHEmptyResultsTableViewCell
            cell.accessoryType      = .none
            cell.setupCellForServices()
            return cell
            
        }
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DKHServiceSummaryTableViewCell", for: indexPath)
                as! DKHServiceSummaryTableViewCell
            cell.accessoryType      = .none
            cell.setupCell(appointment: appointment.appointment[indexPath.row])
            return cell
            
        }else {
            
            if indexPath.row == 2 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "DKHSelectWorkerTableViewCell", for: indexPath) as! DKHSelectWorkerTableViewCell
                if DKHUser.workerAccount {
                    cell.setupCellForSummary(worker: nil,user: appointment.customer)
                }else {
                     cell.setupCellForSummary(worker: appointment.worker,user: nil)
                }
                cell.accessoryType      = .none
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DKHDetailTableViewCell", for: indexPath)
                as! DKHDetailTableViewCell
            
            if indexPath.row == 0 {
                cell.accessoryType          = .none
                cell.setupCellForDate(startDate:appointment.startDate, endDate:appointment.endDate)
            }else if indexPath.row == 1 {
                if DKHUser.workerAccount {
                    cell.accessoryType      = .detailButton
                }
                cell.setupCellForAddress(address: appointment.address)
            }else if indexPath.row == 3 {
                cell.accessoryType      = .none
                cell.setupCellForTotal(total: appointment.totalPrice)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        selectNavigationMethod()
    }
    
    private func selectNavigationMethod() {
        guard let appointment = self.appointment else {
            return
        }
        
        let alert = UIAlertController(title: NSLocalizedString("navigate_title", comment: ""), message: NSLocalizedString("navigate_message", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
            self.navigateWithWaze(locations: appointment.appointmentCoordinates)
            
        }))
        
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("navigate_in_app", comment: ""), style: .default, handler: { (action) in
            let mapViewController = DKHNavigation.navigationToAddressViewController()
            mapViewController.destination = appointment.appointmentCoordinates
            self.navigationController?.pushViewController(mapViewController, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel_button", comment: ""), style: .destructive, handler: {   action in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func navigateWithWaze(locations:CLLocationCoordinate2D) {
        
        if UIApplication.shared.canOpenURL(URL(string:"waze://")!) {
            let string = "waze://?ll=\(locations.latitude),\(locations.longitude)&navigate=yes"
            UIApplication.shared.open(URL(string:string)!, options: [:], completionHandler: nil)
        }else {
            guard let appointment = appointment else {
                return
            }
            SVProgressHUD.showInfo(withStatus: NSLocalizedString("waze_not_installed", comment: ""))
            let mapViewController = DKHNavigation.navigationToAddressViewController()
            mapViewController.destination = appointment.appointmentCoordinates
            self.navigationController?.pushViewController(mapViewController, animated: true)
        }
    }
    
    
    
    @IBAction func bookAction(_ sender: Any) {
        
        
        guard let appointment = appointment else {
            return
        }
        
        if DKHUser.workerAccount {
            //Call services
            if appointment.appointmentStatus == .inProgress {
                finishAppointment()
                
            }else {
                startAppointment()
            }
        }else {
            if appointment.appointmentStatus    == .delivered {
                let rateAppointment = DKHNavigation.rateService()
                let viewController = rateAppointment.topViewController as? DKHRateServiceViewController
                viewController?.appointment = appointment
                viewController?.rateClosure = { appointment in
                    if let appointment = appointment {
                        self.appointment = appointment
                        self.getAppointment()
                    }
                }
                self.present(rateAppointment, animated: true, completion: nil)
            }else {
                SVProgressHUD.show()
                DKHServiceAppointment.scheduleAppointment(endPoint: DKHEndPoint.scheduleAppointment(appointmentUuid: appointment.uuid,isSos:serviceSummary.sosSearch)) { (success) in
                    
                    if success {
                        SVProgressHUD.dismiss()
                        self.performSegue(withIdentifier: "showWorker", sender: nil)
                    }else {
                        SVProgressHUD.showInfo(withStatus: "error")
                    }
                }
            }
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
        guard let appointment = appointment else {
            return
        }
        
        if appointment.appointmentStatus    == .scheduled {
            cancelAppointment()
        }else {
            guard let _ = navigationController?.popToRootViewController(animated: true) else{
                dismiss(animated: true, completion: nil)
                return
            }
        }
    }
    
    private func finishAppointment() {
        guard let appointment = appointment else {
            return
        }
        
        SVProgressHUD.show()
        DKHServiceAppointment.finishAppointment(endPoint: .finishAppointment(appointmentUuid: appointment.uuid)) { (success, currentAppointment) in
            if success {
                guard let currentAppointment = currentAppointment else {
                    return
                }
                
                SVProgressHUD.dismiss()
                self.appointment = currentAppointment
                self.configureViewBasedOnAppointment()
                self.tableView.reloadData()
            }
        }
    }
    
    private func startAppointment() {
        
        guard let appointment = appointment else {
            return
        }
        SVProgressHUD.show()
        DKHServiceAppointment.startAppointment(endPoint: .startAppointment(appointmentUuid: appointment.uuid)) { (success, currentAppointment) in
            if success {
                guard let currentAppointment = currentAppointment else {
                    return
                }
                
                SVProgressHUD.dismiss()
                self.appointment = currentAppointment
                self.configureViewBasedOnAppointment()
                self.tableView.reloadData()
            }
        }
    }
    
    
    private func getAppointment() {
        guard let _ = appointment else {
            
            SVProgressHUD.setDefaultMaskType(.clear)
            bookView?.isHidden = true
            SVProgressHUD.show()
            let utcDate =   serviceSummary.selectedTime.localToUTC()
            DKHServiceAppointment.preScheduleAppointment(endPoint: DKHEndPoint.appointment(startDateTime: utcDate, coustomerUuid: DKHUser.currentUser!.uuid, workerUuid: serviceSummary.worker.uuid, location: serviceSummary.coordinates, address: serviceSummary.address, hasDiscountCoupon: false, discount: "a", services: serviceSummary.services)) { summary, error in
                
                guard let summary = summary else {
                    SVProgressHUD.show(withStatus: error)
                    return
                }
                
                self.appointment = summary
                self.bookView?.isHidden       = false
                self.bookButton?.isEnabled    = true
                self.totalLabel?.text         = NSLocalizedString("terms_conditions", comment: "")
                SVProgressHUD.dismiss()
                self.tableView.reloadData()
                
            }
            return
        }
        
        configureViewBasedOnAppointment()
        
    }
    
    
    private func configureViewBasedOnAppointment() {
        
        guard let appointment = appointment, let user = DKHUser.currentUser else {
            return
        }
        
        if !DKHUser.workerAccount {
            if appointment.appointmentStatus == .delivered  {
                if let _ = appointment.ratings.filter({$0.userUuid == user.uuid}).first, appointment.ratings.count != 0 {
                    bookView?.removeFromSuperview()
                }else {
                    bookButton?.setTitle(NSLocalizedString("rate_title", comment: ""), for: .normal)
                    totalLabel?.isHidden    = true
                    bookButton?.isEnabled   = true
                    cancelButton?.removeFromSuperview()
                }
            }else if appointment.appointmentStatus == .scheduled {
                totalLabel?.removeFromSuperview()
                bookButton?.removeFromSuperview()
                
            }else if appointment.appointmentStatus == .inProgress {
                bookView?.removeFromSuperview()
            }else if appointment.appointmentStatus == .canceled {
                bookView?.removeFromSuperview()
            }
        }else {
            if appointment.appointmentStatus == .scheduled {
                bookButton?.setTitle(NSLocalizedString("start_appointment_button", comment: ""), for: .normal)
                totalLabel?.isHidden    = true
                bookButton?.isEnabled   = true
            }else if appointment.appointmentStatus == .inProgress {
                bookButton?.setTitle(NSLocalizedString("finish_appointment_button", comment: ""), for: .normal)
                totalLabel?.isHidden    = true
                cancelButton?.removeFromSuperview()
            }else if appointment.appointmentStatus == .delivered {
                bookView?.removeFromSuperview()
            }else if appointment.appointmentStatus  == .canceled {
                bookView?.removeFromSuperview()
            }
        }
    }
    
    private func cancelAppointment() {
        guard let appointment = appointment else {
            return
        }
        
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
        
        DKHServiceAppointment.cancelAppointment(endPoint: DKHEndPoint.cancelAppointment(appointmentUuid: appointment.uuid)) { (success) in
            
            SVProgressHUD.dismiss()
            if success {
                self.cancelAppointmentClosure?()
                let _ =  self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWorker" {
            let nextViewController = segue.destination as! DKHShowWorkerViewController
            nextViewController.serviceSummary   = serviceSummary
            nextViewController.dissmissClosure  = {
                self.dismiss(animated: true, completion: nil)
                let _ = self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    
}
