//
//  DKHWorkerAvailabilityViewController.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 5/9/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit
import AlamofireImage
import DateTools
import SBPickerSelector


class DKHWorkerAvailabilityViewController: DKHBaseViewController,UITableViewDelegate,UITableViewDataSource,SBPickerSelectorDelegate {
    
    @IBOutlet weak var bookServiceButton: UIButton!
    @IBOutlet weak var calendarImage: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var workerImage: UIImageView!
    
    @IBOutlet var dateContainer: UIView!
    @IBOutlet weak var workerDescription: UILabel!
    
    var worker:DKHWorker!
    var selectedCell:IndexPath?
    var serviceSummary: DKHServiceSummary!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedDate = Date(timeIntervalSince1970: 0) {
        didSet{
            self.dateLabel.text = (self.selectedDate as NSDate).formattedDate(withFormat: "EEEE dd MMMM").uppercased()
            if dateOptions.count > 1 {
                calendarImage.isHidden = false
            }
        }
    }
    var workerDates:[Date] = [Date]()
    
    var datesFiltered:[Date] {
        let filter =  workerDates.filter({
            let date = ($0.UTCToLocal() as NSDate)
            return (date.isSameDay(self.selectedDate))
        })
        return filter
    }
    
    var dateOptions:[Date] {
        var retArr = [Date]()
        for event in workerDates {
            var isIn = false
            for date in retArr {
                let currentDate = (event.UTCToLocal() as NSDate)
                
                if currentDate.isSameDay(date) {
                    isIn = true
                    break
                }
            }
            if !isIn {
                retArr.append(event)
            }
        }
        return retArr
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate      = self
        tableView.dataSource    = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        if let url = URL(string:worker.imageUrl) {
            workerImage.af_setImage(withURL: url)
        }
        
        tableView.register(UINib(nibName: "DKHEmptyResultsTableViewCell", bundle: nil), forCellReuseIdentifier: "DKHEmptyResultsTableViewCell")
        title                           = "LA FEMME"
        selectedDate                    = Date()
        tableView.rowHeight             = UITableViewAutomaticDimension
        tableView.estimatedRowHeight    = 50
        tableView.tableFooterView       = UIView()
        bookServiceButton.isEnabled     = selectedCell != nil
        bookServiceButton.setBackgroundImage(UIImage.imageFromColor(color: UIColor.programColorDisable(), size: bookServiceButton.frame.size), for: .disabled)
        workerDescription.text          = worker.firstname +  " " + worker.lastname
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return dateContainer
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard datesFiltered.count != 0 else {
            return 1
        }
        return datesFiltered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard datesFiltered.count != 0 else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DKHEmptyResultsTableViewCell", for: indexPath) as! DKHEmptyResultsTableViewCell
            cell.setupCellForAvailability()
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if indexPath == selectedCell {
            cell.textLabel?.textColor   = UIColor.programColor()
            cell.backgroundColor        = UIColor(hex: "#f5f5f5")
            
        }else {
            cell.textLabel?.textColor   = UIColor.black
            cell.backgroundColor        = UIColor.white
        }
        
        
        
        cell.selectionStyle             = .none
        cell.textLabel?.textAlignment   = .center
        cell.textLabel?.text            = ((datesFiltered[indexPath.row]).UTCToLocal() as NSDate).formattedDate(withFormat: "HH:mm a")
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if datesFiltered.count == 0 {
            return 
        }
        
        if selectedCell == indexPath {
            selectedCell = nil
            bookServiceButton.isEnabled = false
        }else {
            selectedCell = indexPath
            bookServiceButton.isEnabled = true
        }
        tableView.reloadData()
    }
    
    @IBAction func changeDate(_ sender: Any) {
        setupPicker()
    }
    
    private func setupPicker() {
        self.view.endEditing(true)
        
        guard dateOptions.count > 1 else {
            return
        }
        
        var pickerData = [String]()
        
        for date in dateOptions {
            if let current = date as NSDate? {
                pickerData.append(current.formattedDate(withFormat: "EEEE dd MMMM").uppercased())
            }
        }
        
        let picker: SBPickerSelector    = SBPickerSelector()
        picker.pickerData               = pickerData
        picker.delegate                 = self
        picker.doneButtonTitle          = "Done"
        picker.cancelButtonTitle        = "Cancel"
        
        picker.pickerType               = SBPickerSelectorType.text
        
        picker.showPickerOver(self) //classic picker display
    }
    
    func pickerSelector(_ selector: SBPickerSelector, selectedValues values: [String], atIndexes idxs: [NSNumber]) {
        for date in dateOptions {
            if let current = date as NSDate? {
                let option = current.formattedDate(withFormat: "EEEE dd MMMM").uppercased()
                if option == values[0] {
                    selectedDate = date
                    tableView.reloadData()
                    break
                }
            }
        }
    }
    
    
    @IBAction func bookAction(_ sender: Any) {
        
        guard let selectedCell = selectedCell else {
            return
        }
        
        serviceSummary.selectedTime = datesFiltered[selectedCell.row].UTCToLocal()
        performSegue(withIdentifier: "summary", sender: nil)
        
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "summary" {
            
            let nextViewC               = segue.destination as! DKHSummaryViewController
            nextViewC.serviceSummary    = serviceSummary
        }
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
    
    
}
