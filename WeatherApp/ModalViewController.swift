//
//  ModalViewController.swift
//  WeatherApp
//
//  Created by Albert Duz on 05/11/2019.
//  Copyright © 2019 Albert Duz. All rights reserved.
//

import UIKit
import CoreLocation

class ModalViewController: UIViewController {
    
    @IBOutlet weak var citiesTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var currentLocationView: UILabel!
    
    @IBAction func onSearch(_ sender: Any) {
        fetchData("query=\(searchTextField.text!)", "")
    }
    
    @IBAction func onClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var masterViewController: MasterViewController? = nil
    
    let locationManager = CLLocationManager()
    
    private var cities: [City] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        citiesTableView.delegate = self
        citiesTableView.dataSource = self
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        } else {
            print("Location not enabled...")
        }
    }
    
    private func getUrl(_ query: String) -> URL {
        return URL(string: "https://www.metaweather.com/api/location/search/?\(query)")!
    }
        
    private func fetchData(_ query: String, _ city: String) {
        URLSession.shared.dataTask(with: getUrl(query)) { (data, response, error) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                self.cities = try decoder.decode([City].self, from: data)
                
                let city = self.cities.filter { $0.title == city }
                
                if (city.count == 1) {
                    self.cities = city
                }
                
                DispatchQueue.main.async {
                    self.citiesTableView.reloadData()
                }
            } catch let err {
                print("Error while parsing", err)
            }
        }.resume()
    }
}

extension ModalViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if let location = locations.last {            
            CLGeocoder().reverseGeocodeLocation(location, preferredLocale: nil) { (clPlacemark: [CLPlacemark]?, error: Error?) in
                guard let placemark = clPlacemark?.first else {
                    print("No placemark from Apple: \(String(describing: error))")
                    self.fetchData("lattlong=\(location.coordinate.latitude),\(location.coordinate.longitude)", "")
                    return
                }
                
                DispatchQueue.main.async {
                    self.currentLocationView.text = "\(placemark.locality ?? "Unknown"), \(placemark.country ?? "Unknown")"
                    self.fetchData("lattlong=\(location.coordinate.latitude),\(location.coordinate.longitude)", placemark.locality ?? "")
                }
            }
        }
    }
}

extension ModalViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = citiesTableView.dequeueReusableCell(withIdentifier: "CityNameCell", for: indexPath)
        let city = self.cities[indexPath.row]
        cell.textLabel?.text = city.title
        
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cities.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        masterViewController?.newCity = self.cities[indexPath.row]
        dismiss(animated: true, completion: nil)
    }
}
