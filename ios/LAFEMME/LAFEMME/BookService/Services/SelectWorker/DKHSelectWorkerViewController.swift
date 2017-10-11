//
//  DKHSelectWorkerViewController.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 5/3/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit
import SVProgressHUD
import DateTools
import SBPickerSelector

class DKHSelectWorkerViewController: DKHBaseViewController, UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var randomWorker: UIButton!
    
    var showError = false
    
    var serviceSummary:DKHServiceSummary!
    var availability:DKHAvailability?
    var selectedCity:DKHCity?
    var selectedPreFilterDate:Date?
    var workersAvailable = [DKHWorker]()
    var calendarBarButton:UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAvailability()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title                               = "LA FEMME"
        tableView.register(UINib(nibName:"DKHSelectWorkerTableViewCell",bundle:nil), forCellReuseIdentifier: "DKHSelectWorkerTableViewCell")
        tableView.register(UINib(nibName:"DKHEmptyResultsTableViewCell",bundle:nil), forCellReuseIdentifier: "DKHEmptyResultsTableViewCell")
        tableView.delegate                  = self
        tableView.rowHeight                 = UITableViewAutomaticDimension
        tableView.estimatedRowHeight        = 100
        tableView.dataSource                = self
        tableView.tableFooterView           = UIView()
        calendarBarButton                   = Appearance.barButtonWithImage(image: UIImage(named:"calendar"), target: self, action: #selector(setupPicker))
        navigationItem.rightBarButtonItem   = calendarBarButton
    }
    
    
    func preFilterByDate() {
        guard let filteredDate = selectedPreFilterDate else {
            return
        }

        let available = workersAvailable.filter({ worker in
            
            
            for currentDate in worker.workerDates {
                let  date = currentDate.date.UTCToLocal() as NSDate
                if date.isEqual(to:filteredDate) {
                    return true
                }
            }
            return false
        })
        workersAvailable = available
    }
    
    func setupPicker() {
        
        navigationItem.rightBarButtonItem   = Appearance.barButtonWithTitle(title: NSLocalizedString("clear_filter",comment: ""), target: self, action: #selector(clearDatesFIltered))
        let picker: SBPickerSelector            = SBPickerSelector()
        picker.pickerType                       = SBPickerSelectorType.date
        picker.datePickerView.minuteInterval    = 30
        //picker.pickerData               = pickerData
        picker.delegate                         = self
        picker.doneButtonTitle                  = "Done"
        picker.cancelButtonTitle                = "Cancel"
        
        picker.showPickerOver(self) //classic picker display
        
    }
    
    func clearDatesFIltered() {
        
        navigationItem.rightBarButtonItem = calendarBarButton
        guard let availability = availability else {
            return
        }

        workersAvailable = Array(availability.workers)
        tableView.reloadData()
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard  let availability = availability, availability.workers.count != 0  else {
            if showError {
                return 1
            }
            return 0
        }
        
        return workersAvailable.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard  workersAvailable.count != 0 else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DKHEmptyResultsTableViewCell", for: indexPath) as! DKHEmptyResultsTableViewCell
            cell.setupCellForWorkers()
            return cell
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DKHSelectWorkerTableViewCell", for: indexPath) as! DKHSelectWorkerTableViewCell
        cell.setupCell(worker: workersAvailable[indexPath.row])
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let availability = availability, availability.workers.count != 0 else {
            return
        }
        handleWorkerSelection(indexPath: indexPath.row)
    }
    
    
    @IBAction func randomWorker(_ sender: Any) {
        guard let availability = availability, availability.workers.count != 0 else {
            return
        }
        let random = Int(arc4random_uniform(UInt32(availability.workers.count)))  // Int(arc4random(availability.workers.count) + 1)
        if random < availability.workers.count {
            handleWorkerSelection(indexPath: random)
        }
        
    }
    
    func handleWorkerSelection(indexPath:Int) {
        guard let availability = availability else {
            return
        }
        
        if serviceSummary!.sosSearch! {
            
            guard let date = Array(workersAvailable[indexPath].dates.map({$0.date})).first else {
                return
            }
            let nextViewController              = DKHNavigation.summaryViewCotroller()
            serviceSummary.worker               = availability.workers[indexPath]
            serviceSummary.selectedTime         = date.UTCToLocal()
            nextViewController.serviceSummary   = serviceSummary
            self.navigationController?.pushViewController(nextViewController, animated: true)
            
        }else {
            
            let nextViewController = DKHNavigation.selectWorkerAvailability()
            //segue.destination as! DKHWorkerAvailabilityViewController
            nextViewController.worker           = workersAvailable[indexPath]
            serviceSummary.worker               = workersAvailable[indexPath]
            nextViewController.serviceSummary   = serviceSummary
            nextViewController.workerDates      = workersAvailable[indexPath].dates.map({$0.date})
            self.navigationController?.pushViewController(nextViewController, animated: true)
            
        }
    }
    
    func getAvailability() {
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show()
        
        DKHAvailability.getAvailability(endPoint: DKHEndPoint.getAvailability(workerUuid: nil, fromDate: NSDate().formattedDate(withFormat: "yyyy-MM-dd"), toDate:NSDate(timeInterval: 864000, since: Date()).formattedDate(withFormat: "yyyy-MM-dd"), coordinates: serviceSummary.coordinates, services: serviceSummary.services), clousure: { (availability) in
            
            self.availability = availability
            if availability.workers.count == 0 {
                self.showError = true
            }
            self.workersAvailable = Array(availability.workers)
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
            
        }, errorClosure: {error in
            
            self.showError = true
            guard let error = error else {
                
                self.tableView.reloadData()
                return
            }
            SVProgressHUD.showInfo(withStatus: error)
            
            self.tableView.reloadData()
            
        })
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if  segue.identifier == "worker_availability" {
            
            guard let availability = availability, let indexPath = sender as? Int else {
                return
            }
            
            let nextViewController = segue.destination as! DKHWorkerAvailabilityViewController
            nextViewController.worker           = availability.workers[indexPath]
            serviceSummary.worker               = availability.workers[indexPath]
            nextViewController.serviceSummary   = serviceSummary
            nextViewController.workerDates      = Array(availability.workers[indexPath].dates.map({$0.date}))
            
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
}

extension DKHSelectWorkerViewController:SBPickerSelectorDelegate {
    
    func pickerSelector(_ selector: SBPickerSelector, dateSelected date: Date) {
        selectedPreFilterDate = (date as NSDate).subtractingSeconds((date as NSDate).second())
        preFilterByDate()
        self.tableView.reloadData()
    }
    
}
