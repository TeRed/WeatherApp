//
//  MasterViewController.swift
//  WeatherApp
//
//  Created by Albert Duz on 05/11/2019.
//  Copyright © 2019 Albert Duz. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    
    var cities: [City] = [City(title: "London", woeid: 44418), City(title: "San Francisco", woeid: 2487956), City(title: "Warsaw", woeid: 523920)]
    var citiesWeather: [Int: WeatherData] = [:]
    
    var newCity: City? {
        didSet {
            self.cities.append(newCity!)
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(openModal(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc
    func openModal(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = storyboard.instantiateViewController(withIdentifier: "ModalViewController") as! ModalViewController
        destinationViewController.masterViewController = self
        present(destinationViewController, animated: true, completion: { })
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let city = cities[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.woeid = city.woeid
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
            }
        }
        if segue.identifier == "showModal" {
           let vc: ModalViewController = segue.destination as! ModalViewController
           vc.masterViewController = self
       }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CityInfoCell", for: indexPath) as? CityInfoCellTableView
        else {
            fatalError("The dequeued cell is not an instance of CityInfoCellTableView.")
        }
        let city = cities[indexPath.row]
        cell.cityView.text = city.title
        self.updateCell(cell, city)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.cities.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Fetching
    
    func updateCell(_ cell: CityInfoCellTableView, _ city: City) {
        if let weatherData = self.citiesWeather[city.woeid!] {
            cell.tempView.text = "\(String(format: "%.2f", weatherData.the_temp!)) °C"
            cell.weatherImageView.image = UIImage(named: weatherData.weather_state_abbr!)
        }
        
        URLSession.shared.dataTask(with: URL(string: "https://www.metaweather.com/api/location/\(city.woeid!)/")!)
        { (data, response, error) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let weatherCombined = try decoder.decode(WeatherCombined.self, from: data)

                let weatherData = weatherCombined.consolidated_weather[0]
                
                self.citiesWeather[city.woeid!] = weatherData

                DispatchQueue.main.async {
                    cell.tempView.text = "\(String(format: "%.2f", weatherData.the_temp!)) °C"
                    cell.weatherImageView.image = UIImage(named: weatherData.weather_state_abbr!)
                }
            } catch let err {
                print("Error while parsing", err)
            }
        }.resume()
    }
}

