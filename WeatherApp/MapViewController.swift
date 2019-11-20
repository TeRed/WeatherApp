//
//  MapViewController.swift
//  WeatherApp
//
//  Created by Albert Duz on 16/11/2019.
//  Copyright © 2019 Albert Duz. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let regionRadius: CLLocationDistance = 5000
    
    var place: String?
    
    func getLatt() -> Double {
        guard let val_string = place?.components(separatedBy: ",")[0] else { return 0 }
        
        guard let val = Double(val_string.trimmingCharacters(in: .whitespacesAndNewlines)) else { return 0 }
        
        return val
    }
    
    func getLong() -> Double {
        guard let val_string = place?.components(separatedBy: ",")[1] else { return 0 }
        
        guard let val = Double(val_string.trimmingCharacters(in: .whitespacesAndNewlines)) else { return 0 }
        
        return val
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: self.regionRadius,
                                                  longitudinalMeters: self.regionRadius)
        self.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func addAnnotation(location: CLLocation) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView.addAnnotation(annotation)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let initialLocation = CLLocation(latitude: getLatt(), longitude: getLong())
        centerMapOnLocation(location: initialLocation)
        addAnnotation(location: initialLocation)
    }
}
