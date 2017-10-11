//
//  DKHWorkerHomeViewController.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 5/30/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit
import SVProgressHUD
import CoreLocation
import DateTools
import RealmSwift
import UserNotifications


class DKHWorkerSos:NSObject {
    static let shared = DKHWorkerSos()
    var isSOSOn = false
    var lastLocation:CLLocationCoordinate2D?
    var locationTimer   = Timer()
    var deadLine:Date!
    var dateToCompare:Date!
    var shouldDisableSos = false
    
    
    func startUpdatingLocation() {
        deadLine                    = Date(timeIntervalSinceNow: 60*30)
        UNUserNotificationCenter.current().scheduleNotification(at: deadLine, withTitle: NSLocalizedString("timeout_sos", comment: ""), body: NSLocalizedString("timeout_message", comment: ""), identifier: "sos")
        locationTimer               = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateLocation), userInfo: nil, repeats: true)
    }
    
    func updateLocation() {
        dateToCompare = Date()
        NotificationCenter.default.post(name: NSNotification.Name("updateLocation"), object:nil)
    }
}

class DKHWorkerHomeViewController: DKHBaseViewController,UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var appointmentSegmentedControl: UISegmentedControl!
    @IBOutlet var appointmentFilterView: UIView!
    
    var appointments = [DKHServiceAppointment]()
    var filteredAppointments = [DKHServiceAppointment]()
    
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var tableView: UITableView!
    var userLocation:CLLocationCoordinate2D?
    var locationManager = CLLocationManager()
    var currentLocation:CLLocationCoordinate2D?
    
    @IBOutlet weak var sosSwitch: UISwitch!
    var sosHandler = DKHWorkerSos.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource    = self
        tableView.delegate      = self
        locationManager.delegate        = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if sosHandler.shouldDisableSos {
            sosSwitch.setOn(false, animated: true)
            sosHandler.isSOSOn          = false
            sosHandler.shouldDisableSos = false
        }
        
        getAppointments()
        // changeAppointmentFilterAction(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        tableView.rowHeight                     = UITableViewAutomaticDimension
        tableView.estimatedRowHeight            = 100
        tableView.tableFooterView               = UIView()
        appointmentFilterView.backgroundColor   = UIColor.programColorLight()
        tableView.tableHeaderView               = appointmentFilterView
        addPullToRefesh()
        title                                   = "LA FEMME"
        appointmentSegmentedControl.setTitle(NSLocalizedString("current_active_services", comment: ""), forSegmentAt: 0)
        appointmentSegmentedControl.setTitle(NSLocalizedString("history_services", comment: ""), forSegmentAt: 1)
        tableView.register(UINib(nibName:"DKHMyAppointmentsTableViewCell",bundle:nil), forCellReuseIdentifier: "DKHMyAppointmentsTableViewCell")
        if let user = DKHUser.currentUser {
            sosSwitch.setOn(user.SOS, animated: true)
        }
        
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredAppointments.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DKHMyAppointmentsTableViewCell", for: indexPath) as! DKHMyAppointmentsTableViewCell
        let currentAppointment = filteredAppointments[indexPath.row]
        var leftViewColor:UIColor?
        
        leftViewColor = indexPath.row % 2 == 0 ? UIColor(hex:"#b7b6e0"):UIColor(hex:"#a7a6cf")
        
        
        cell.setupCell(startDate: currentAppointment.startDate, endDate: currentAppointment.endDate,leftViewColor: leftViewColor)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailService = DKHNavigation.summaryViewCotroller()
        detailService.appointment   = filteredAppointments[indexPath.row]
        detailService.cancelAppointmentClosure = {
            
            Realm.update(updateClosure: { (realm) in
                realm.delete(self.filteredAppointments[indexPath.row])
                self.filteredAppointments.remove(at: indexPath.row)
            })
            
            self.tableView.reloadData()
        }
        self.navigationController?.pushViewController(detailService, animated: true)
        
    }
    
    private func getAppointments() {
        
        SVProgressHUD.show()
        DKHServiceAppointment.all(endPoint: .appointments(workerUuid: "")) { (appointments) in
            
            self.refreshControl.endRefreshing()
            
            guard let newAppointments =  appointments else {
                return
            }
            
            self.appointments   = newAppointments
            self.changeAppointmentFilterAction(self)
            //self.tableView.reloadData()
            SVProgressHUD.dismiss()
        }
    }
    
    func addPullToRefesh() {
        refreshControl.addTarget(self, action: #selector(refesh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func refesh() {
        getAppointments()
    }
    
    @IBAction func activateSOS(_ sender: Any) {
        SVProgressHUD.show()
        guard let currentLocation = currentLocation else {
            SVProgressHUD.showInfo(withStatus:NSLocalizedString("location_sos_error", comment: ""))
            return
        }
        
        
        
        DKHWorker.activateSOS(endPoint: .tongleSOS(location: currentLocation)) { (worker, error) in
            SVProgressHUD.dismiss()
            guard let worker = worker, error == nil else {
                SVProgressHUD.showInfo(withStatus: "can_not_activate_sos")
                return
            }
            if error == nil {
                if self.sosSwitch.isOn {
                    self.sosHandler.startUpdatingLocation()
                    NotificationCenter.default.addObserver(self, selector: #selector(self.updateLocation), name: NSNotification.Name("updateLocation"), object: nil)
                }else {
                    self.sosHandler.locationTimer.invalidate()
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    NotificationCenter.default.removeObserver(self)
                }
                self.sosHandler.isSOSOn         = worker.SOS
                self.sosHandler.lastLocation    = worker.lastKnowlocation
                
            }
        }
    }
    
    
    func updateLocation() {
        guard let currentLocation = currentLocation else {
            SVProgressHUD.showInfo(withStatus:NSLocalizedString("location_sos_error", comment: ""))
            return
        }
        
        DKHWorker.updateLocation(endPoint: .lastLocation(location: currentLocation)) { (worker, error) in
            guard let worker = worker, error == nil else {
                SVProgressHUD.showInfo(withStatus: "can_not_activate_sos")
                return
            }
            
            self.sosHandler.isSOSOn         = worker.SOS
            self.sosHandler.lastLocation    = worker.lastKnowlocation
        }
    }
    
    
    @IBAction func changeAppointmentFilterAction(_ sender: Any) {
        
        var sorted = appointments.sorted(by: { (lhsData, rhsData) -> Bool in
            return lhsData.startDate < rhsData.startDate
        })
        
        if appointmentSegmentedControl.selectedSegmentIndex == 0 {
            
            sorted = sorted.filter({$0.appointmentStatus == .scheduled || $0.appointmentStatus == .inProgress})
            filteredAppointments =  sorted
        }else {
            sorted = sorted.filter({$0.appointmentStatus == .delivered})
            filteredAppointments =  sorted
        }
        
        tableView.reloadData()
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

extension DKHWorkerHomeViewController:CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        currentLocation = manager.location?.coordinate
        sosHandler.lastLocation = currentLocation
        manager.stopUpdatingLocation()
        
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        currentLocation = manager.location?.coordinate
        sosHandler.lastLocation = currentLocation
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location.coordinate
            sosHandler.lastLocation = currentLocation
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        currentLocation = nil
    }
}

