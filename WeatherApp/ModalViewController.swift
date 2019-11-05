//
//  ModalViewController.swift
//  WeatherApp
//
//  Created by Albert Duz on 05/11/2019.
//  Copyright © 2019 Albert Duz. All rights reserved.
//

import UIKit

class ModalViewController: UIViewController {
    
    @IBOutlet weak var citiesTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!

    @IBAction func onSearch(_ sender: Any) {
        fetchData(searchTextField.text!)
    }
    
    @IBAction func onClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var masterViewController: MasterViewController? = nil
    
    private var cities: [City] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        citiesTableView.delegate = self
        citiesTableView.dataSource = self
    }
    
    private func getUrl(_ query: String) -> URL {
        return URL(string: "https://www.metaweather.com/api/location/search/?query=\(query)")!
    }
        
    private func fetchData(_ query: String) {
        URLSession.shared.dataTask(with: getUrl(query)) { (data, response, error) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                self.cities = try decoder.decode([City].self, from: data)
                
                DispatchQueue.main.async {
                    self.citiesTableView.reloadData()
                }
            } catch let err {
                print("Error while parsing", err)
            }
        }.resume()
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
