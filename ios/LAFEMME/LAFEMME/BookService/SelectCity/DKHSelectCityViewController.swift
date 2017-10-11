//
//  DKHSelectCityViewController.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 7/9/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit
import RealmSwift
import SBPickerSelector
import SVProgressHUD
import CoreLocation

class DKHSelectCityViewController: DKHBaseViewController,SBPickerSelectorDelegate {
    
    @IBOutlet weak var selectedCityLabel: UILabel!
    var cities = [DKHCity]()
    var selectedCity:DKHCity?
    var userLocation:CLLocationCoordinate2D?
    let picker: SBPickerSelector    = SBPickerSelector()
    
    @IBOutlet weak var selectCityTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCities()
        // Do any additional setup after loading the view.
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        guard let user = DKHUser.currentUser else {
            return
        }
        
        selectedCityLabel.text   = "Medellín"
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupPicker() {
        self.view.endEditing(true)
        
        picker.pickerData               = sortCities() //picker content
        picker.delegate                 = self
        picker.pickerType               = SBPickerSelectorType.text
        picker.doneButtonTitle          = "Done"
        picker.cancelButtonTitle        = "Cancel"
        
        picker.showPickerOver(self) //classic picker display
        
    }
    
    
    //MARK: - Picker Delegate
    
    func pickerSelector(_ selector: SBPickerSelector, selectedValues values: [String], atIndexes idxs: [NSNumber]) {
        
        
        
        selectedCityLabel.text = values.first
        
        
        //cityTextField.text  = values.first
        //city.value  = values.first!
    }
    
    @IBAction func continueButtonAction(_ sender: Any) {
        if let selectedCityString = selectedCityLabel.text {
            selectedCity    = cities.filter({$0.cityName == selectedCityString}).first
        }
        

        guard let selectedCity = selectedCity else {
            SVProgressHUD.showInfo(withStatus: "no_services_available")
            return
        }
        
        if !selectedCity.selectable {
             SVProgressHUD.showInfo(withStatus: "no_services_available")
            return
        }
        
        let serviceViewController               = DKHNavigation.selectService()
        let serviceSummary                      = DKHServiceSummary()
        serviceSummary.sosSearch                = false
        serviceViewController.selectedCity      = selectedCity
        serviceViewController.servicesSummary   = serviceSummary
        serviceViewController.userLocation      = selectedCity.coordinates
        self.navigationController?.pushViewController(serviceViewController, animated:true)
        
    }
    
    @IBAction func selectCityAction(_ sender: Any) {
        setupPicker()
    }
    
    private func  getCities() {
        SVProgressHUD.show()
        DKHCity.all(endPoint: DKHEndPoint.getCities(country: nil, city: nil)) { (allCities) in
            SVProgressHUD.dismiss()
            guard let all = allCities else {
                return
            }
            self.cities = all
        }
    }
    
    private func sortCities() -> [String] {
        
        if cities.count == 0 {
            return []
        }
        
        let mde     = cities.filter({$0.cityName == "Medellín"}).first
        if let mde = mde {
            return [mde.cityName]
        }else {
            return []
        }
        //        //        let bog     = cities.filter({$0.cityName == "Bogotá"}).first
        //        //        let env     = cities.filter({$0.cityName == "Envigado"}).first
        //        //        let itg     = cities.filter({$0.cityName == "Itagüi"}).first
        //        //        let zbn     = cities.filter({$0.cityName == "Zabaneta"}).first
        //
        //
        //        var array = cities.map({$0.cityName}).sorted(by: {$0.0 < $0.1})
        //        if let mde = mde {
        //            array.removeObject(object: mde)
        //        }
        //        array.insert(mde!.cityName, at: 0)
        //
        //        return array
    }
    
}
