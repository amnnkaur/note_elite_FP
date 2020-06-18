//
//  LocationViewController.swift
//  note_elite_FP
//
//  Created by Anmol singh on 2020-06-18.
//  Copyright © 2020 Aman Kaur. All rights reserved.
//

import UIKit
import MapKit

class LocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var locationMapView: MKMapView!
    var coordinates: CLLocationCoordinate2D?
    var locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        intials()
    }
    
    func intials() {
        

            // we give delegate to location manager to this class
                locationManager.delegate = self
        
            // accuracy of the location
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
            // request user for location
                locationManager.requestWhenInUseAuthorization()
        
            //start updating the location of the user
                locationManager.startUpdatingLocation()
        
                locationMapView.delegate = self
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let latitude = coordinates!.latitude
        let longitude = coordinates!.longitude
               
            let latDelta: CLLocationDegrees = 0.05
            let longDelta: CLLocationDegrees = 0.05
               
        // 3 - Creating the span, location coordinate and region
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
            let customLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region = MKCoordinateRegion(center: customLocation, span: span)
                     
        // 4 - assign region to map
            locationMapView.setRegion(region, animated: true)
    }
    
}
