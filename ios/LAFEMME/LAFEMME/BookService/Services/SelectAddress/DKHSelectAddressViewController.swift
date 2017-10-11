//
//  DKHSelectAddressViewController.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 4/25/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit
import Alamofire
import Foundation
import MapKit
import AlamofireObjectMapper
import CoreLocation
import SVProgressHUD
import RealmSwift
import GooglePlaces

class DKHSelectAddressViewController: DKHBaseViewController, CLLocationManagerDelegate,UITextFieldDelegate,UISearchDisplayDelegate {
    
    @IBOutlet weak var continueButton: UIButton!
    let locationManger = CLLocationManager()
    let point = MKPointAnnotation()
    var serviceSummary:DKHServiceSummary!
    var selectedCity:DKHCity?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var selectedAddressLabel: UILabel!
    @IBOutlet weak var aditionalInformationTextField: UITextField!
    
    var recomendationAddress    = [DKHLocation]()
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    var currentTextField:UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate                = self
        locationManger.delegate         = self
        
        GMSPlacesClient.provideAPIKey("AIzaSyBz3LK2gHHUrOJQfnWUIXVpeComNxHC01I")
        locationManger.requestAlwaysAuthorization()
        locationManger.requestWhenInUseAuthorization()
        locationManger.desiredAccuracy  = kCLLocationAccuracyBestForNavigation
        locationManger.startUpdatingLocation()
        
        setupMapView()
        NotificationCenter.default.addObserver(self, selector: #selector(moveKeyboard(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(moveKeyboard(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title                                   = "LA FEMME"
        let trackUser                           = MKUserTrackingBarButtonItem(mapView: mapView)
        navigationItem.rightBarButtonItem       = trackUser
        aditionalInformationTextField.delegate  = self
        if serviceSummary.sosSearch {
            getCityNameInSOS()
        }
    
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        locationManger.stopUpdatingLocation()
    }
    
    private func setupMapView() {
        // mapView.removeAnnotations(mapView.annotations)
        
        point.title = NSLocalizedString("location_message", comment: "")
        point.coordinate = mapView.userLocation.coordinate
        mapView.addAnnotation(point)
        setPointAnnotation(coords: mapView.userLocation.coordinate)
        
    }
    
    func clearAddressText() {
        continueButton.isEnabled        = false
        continueButton.backgroundColor  = UIColor.programColorDisable()
    }
    
    
    private func setPointAnnotation(coords:CLLocationCoordinate2D) {
        //mapView.removeAnnotation(mapView.annotations)
        point.coordinate = coords
        let region = mapView.regionThatFits(MKCoordinateRegionMake(coords, MKCoordinateSpan(latitudeDelta: 0.0020, longitudeDelta: 0.0020)))
        
        mapView.setRegion(region, animated: true)
        
    }
    
    func centerMapWithCoords(coordinates:CLLocationCoordinate2D) {
        
        var zoomRect:MKMapRect              = MKMapRectNull
        let coord:CLLocationCoordinate2D    = coordinates
        let annotationPoint: MKMapPoint     = MKMapPointForCoordinate(coord)
        let pointRect:MKMapRect             = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0)
        
        zoomRect = MKMapRectUnion(zoomRect, pointRect)
        
        mapView.setVisibleMapRect(zoomRect, edgePadding:UIEdgeInsetsMake(50, 50, 50, 50), animated:true)
    }
    
    
    func moveKeyboard(notification:NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        if notification.name == NSNotification.Name.UIKeyboardWillHide {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                
                self.view.frame.origin.y = 64
            })
            
        }else {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                guard let navigation = self.navigationController else {
                    return
                }
                let min = navigation.navigationBar.frame.maxY
                
                let value = keyboardFrame.height - (self.view.frame.height - (self.currentTextField?.frame.maxY ?? 35) - 5)
                self.view.frame.origin.y = -(self.clamp(value: value, minValue: -min, maxValue:keyboardFrame.height))
                
                // self.view.frame.origin.y = -(keyboardFrame.size.height * 0.4)
            })
        }
    }
    
    func clamp<T : Comparable>(value: T, minValue: T, maxValue: T) -> T {
        return min(maxValue, max(minValue, value))
    }

    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        currentTextField = nil
        if textField == aditionalInformationTextField {
            return
        }
        guard let text = textField.text, !text.isEmpty else {
            continueButton.isEnabled = false
            continueButton.backgroundColor  = UIColor.programColorDisable()
            return
        }
        
        continueButton.isEnabled        = true
        continueButton.backgroundColor  = UIColor.programColor()
        
        DKHLocation.getCordsFromAddress(endpoint: DKHEndPoint.getUserLocationByAddress(address: text)) { (location, error) in
            guard let firstLocation = location.first, error == nil else {
                // SVProgressHUD.showError(withStatus: "Error")
                return
            }
            self.recomendationAddress   = location
            self.createPoint(coords: firstLocation.coords)
            //self.centerMapWithCoords(coordinates: location.first!.coords)
            self.selectedAddressLabel.text  = firstLocation.formattedAdrress
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        currentTextField = nil
        return true
    }
    
    
    private func getCityNameInSOS() {
        Realm.update { (realm) in
            let cities = Array(realm.objects(DKHCity.self))
            
            let currentLocation = CLLocation(latitude: self.point.coordinate.latitude, longitude: self.point.coordinate.longitude)
            self.fetchCountryAndCity(location: currentLocation) { country, currentCity in
                if let city = cities.filter({$0.cityName.folding(options: .diacriticInsensitive, locale: .current) == currentCity}).first {
                    self.selectedCity = city
                }
            }
        }
        
    }
    
    func fetchCountryAndCity(location: CLLocation, completion: @escaping (String, String) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print(error)
            } else if let country = placemarks?.first?.country,
                let city = placemarks?.first?.locality {
                completion(country, city)
            }
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinates = locations.last?.coordinate  else {
            return
        }
        continueButton.isEnabled = true
        continueButton.backgroundColor  = UIColor.programColor()
        getAddressFormCords(coord: coordinates)
    }
    
    func getAddressFormCords(coord:CLLocationCoordinate2D) {
        
        DKHLocation.getAddressFromCoords(endpoint: DKHEndPoint.getUserLocation(coords: coord, sensor: true)) { (location, error) in
            guard let firstLocation = location.first, error == nil else {
                return
            }
            self.recomendationAddress       = location
            self.selectedAddressLabel.text  = location.first?.formattedAdrress
            self.createPoint(coords: firstLocation.coords)
            self.locationManger.stopUpdatingLocation()
            
        }
    }
    
    
    func createPoint(coords:CLLocationCoordinate2D) {
        mapView.removeAnnotations(mapView.annotations)
        self.point.title = ""
        self.point.coordinate = coords
        self.mapView.addAnnotation(self.point)
        self.setPointAnnotation(coords: coords)
    }
    
    
    @IBAction func continueAction(_ sender: Any) {
    
        guard let aditionalInfo = aditionalInformationTextField.text, !aditionalInfo.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        serviceSummary.address      = selectedAddressLabel.text
        serviceSummary.address      = serviceSummary.address + " " + "Casa o Apto " + aditionalInfo
        serviceSummary.coordinates  = point.coordinate
        
        if !serviceSummary.sosSearch {
            performSegue(withIdentifier: "select_worker", sender: nil)
        }else {
            let service = DKHNavigation.selectService()
            service.userLocation    = point.coordinate
            service.servicesSummary = serviceSummary
            self.navigationController?.pushViewController(service, animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.createPoint(coords: recomendationAddress[indexPath.row].coords)
        tableView.isHidden = true
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text    = recomendationAddress[indexPath.row].formattedAdrress
        cell.textLabel?.font    = UIFont.systemFont(ofSize: 11)
        
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recomendationAddress.count
    }
    
    
}

extension DKHSelectAddressViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation
        {
            return nil
        }
        
        var annotationView:MKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationKey") as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotationKey")
        }
        
        //annotationView?.image = UIImage(named:"mapPin")
        annotationView?.isDraggable     = true
        annotationView?.canShowCallout  = false
        annotationView?.animatesDrop    = true
        
        return annotationView
    }
    
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Add new annotation
        
        if mapView.userLocation.coordinate.latitude != 0 {
            point.coordinate = mapView.centerCoordinate
            
            DKHLocation.getAddressFromCoords(endpoint: DKHEndPoint.getUserLocation(coords: point.coordinate, sensor: true)) { (location, error) in
                guard let firstLocation = location.first, error == nil else {
                    //SVProgressHUD.showError(withStatus: "Error")
                    return
                }
                self.continueButton.isEnabled           = true
                self.continueButton.backgroundColor     = UIColor.programColor()
                self.selectedAddressLabel.text          = firstLocation.formattedAdrress

            }
            
            self.mapView.addAnnotation(point)
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        
        if newState == .none {
            DKHLocation.getAddressFromCoords(endpoint: DKHEndPoint.getUserLocation(coords: view.annotation!.coordinate, sensor: true)) { (location, error) in
                guard let firstLocation = location.first, error == nil else {
                    //SVProgressHUD.showError(withStatus: "Error")
                    return
                }
                self.continueButton.isEnabled           = true
                self.continueButton.backgroundColor     = UIColor.programColor()
                self.selectedAddressLabel.text          = firstLocation.formattedAdrress
            }
        }
    }
    
    
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        if mode == .follow {
            self.createPoint(coords: mapView.userLocation.coordinate)
            self.getAddressFormCords(coord: mapView.userLocation.coordinate)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "select_worker" {
            let nextViewController = segue.destination as! DKHSelectWorkerViewController
            nextViewController.serviceSummary   = serviceSummary
        }
    }
}

extension DKHSelectAddressViewController:GMSAutocompleteResultsViewControllerDelegate {
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        selectedAddressLabel.text               = place.formattedAddress
        self.createPoint(coords: place.coordinate)
        
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

