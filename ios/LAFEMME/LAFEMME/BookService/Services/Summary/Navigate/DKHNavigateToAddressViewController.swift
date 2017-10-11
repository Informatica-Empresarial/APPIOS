//
//  DKHNavigateToAddressViewController.swift
//  LAFEMME
//
//  Created by Daniel Klinkert Houfer on 6/11/17.
//  Copyright © 2017 Daniel Klinkert Houfer. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import Polyline
import SVProgressHUD


class DKHNavigateToAddressViewController: DKHBaseViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    let locationManger = CLLocationManager()
    var destination:CLLocationCoordinate2D!
    var lastLocation:CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        locationManger.requestAlwaysAuthorization()
        locationManger.requestWhenInUseAuthorization()
        locationManger.delegate = self
        locationManger.startUpdatingLocation()
        locationManger.desiredAccuracy  = kCLLocationAccuracyBestForNavigation
        // Do any additional setup after loading the view.
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer            = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.lineWidth      = 3
        renderer.strokeColor    = UIColor.programColor()
        return renderer
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManger.stopUpdatingLocation()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        let trackUser = MKUserTrackingBarButtonItem(mapView: mapView)
        navigationItem.rightBarButtonItem = trackUser
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count >= 1 {
            guard let lastLocation = locations.last else {
                return
            }
            getDirections(locations: lastLocation.coordinate)
            self.lastLocation = lastLocation
        }
    }
    
    
    func getDirections(locations:CLLocationCoordinate2D){
        Alamofire.request("https://maps.googleapis.com/maps/api/directions/json?origin=\(locations.latitude),\(locations.longitude)&destination=\(destination.latitude),\(destination.longitude)&key=AIzaSyCWlPpHGwjFNDfuI-1jdFPjE6Z7ERaJF8w").responseJSON { response in
            
            if let JSON = response.result.value as? [String:Any], response.response?.statusCode == 200 {
                if let routes = JSON["routes"] as? [[String:Any]] {
                    if let poly = routes[0]["overview_polyline"] as? [String:Any] {
                        if let point = poly["points"] as? String {
                            let line = Polyline(encodedPolyline: point)
                            
                            if let polyLine = line.mkPolyline {
                                self.mapView.removeOverlays(self.mapView.overlays)
                                self.mapView.add(polyLine)
                            }
                        }
                    }
                }
            }
        }
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
