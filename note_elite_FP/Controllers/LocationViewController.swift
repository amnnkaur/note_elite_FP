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
//    var destinationCoordinates : CLLocationCoordinate2D!
    var lat: Double = 0.0
    var long: Double = 0.0
    
    var locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        locationMapView.isZoomEnabled = false
        // Do any additional setup after loading the view.
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
               tap.numberOfTapsRequired = 2
               locationMapView.addGestureRecognizer(tap)
        
        intials()
        
        let annotation = MKPointAnnotation()

        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)

       let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: lat, longitude: long)) { (placemarks, error) in
            if let places = placemarks {
                for place in places {
                    annotation.title = place.name
                    annotation.subtitle = "\(place.locality!) ,  \(place.postalCode!)"
                }
            }
        }

        locationMapView.addAnnotation(annotation)
        print(locationMapView.annotations[0].coordinate)
    }
    @IBAction func doneBtn(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
        print(locationMapView.annotations[0].coordinate)
        self.lat = locationMapView.annotations[0].coordinate.latitude
        self.long = locationMapView.annotations[0].coordinate.longitude
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
        
//       initialCoodinates()
//        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
//                    tap.numberOfTapsRequired = 2
//                    locationMapView.addGestureRecognizer(tap)
        
    }
    @objc func handleTap(recognizer: UIGestureRecognizer) {
                  let mapAnnotations  = self.locationMapView.annotations
                           self.locationMapView.removeAnnotations(mapAnnotations)
                           let tapLocation = recognizer.location(in: locationMapView)
                           let tapCoordinates = locationMapView.convert(tapLocation, toCoordinateFrom: locationMapView)
        self.lat = tapCoordinates.latitude
        self.long = tapCoordinates.longitude
                               
                               if recognizer.state == .ended
                               {
                                   
                                    let annotation = MKPointAnnotation()
                                annotation.coordinate.latitude = self.lat
                                annotation.coordinate.longitude = self.long
                //                    annotation.title = "Your destination"
                                let geocoder = CLGeocoder()
                                geocoder.reverseGeocodeLocation(CLLocation(latitude: lat, longitude: long)) { (placemarks, error) in
                                    if let places = placemarks {
                                        for place in places {
                                            annotation.title = place.name
                                            annotation.subtitle = "\(place.locality!) ,  \(place.postalCode!)"
                                        }
                                    }
                                }
                                    self.locationMapView.addAnnotation(annotation)
                               }
                   
               }


    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let latitude = lat
        let longitude = long

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
extension LocationViewController {
    
       func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    
    
            if annotation is MKUserLocation {
                return nil
            }
               let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                pinAnnotation.pinTintColor = .systemPink
                pinAnnotation.isDraggable = false
                pinAnnotation.canShowCallout = true
                
        return pinAnnotation
    
        }
    
    
}
