//
//  DetailViewController.swift
//  WeatherApp
//
//  Created by Albert Duz on 05/11/2019.
//  Copyright © 2019 Albert Duz. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var weatherStateView: UILabel!
    @IBOutlet weak var maxTemperatureView: UILabel!
    @IBOutlet weak var minTemperatureView: UILabel!
    @IBOutlet weak var windSpeedView: UILabel!
    @IBOutlet weak var windDirectionView: UILabel!
    @IBOutlet weak var humidityView: UILabel!
    @IBOutlet weak var airPressureView: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var currentDateView: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var navBarView: UINavigationItem!
    
    @IBAction func onNextButton(_ sender: Any) {
        updateButtons(1)
        updateView()
    }
    
    @IBAction func onPrevButton(_ sender: Any) {
        updateButtons(-1)
        updateView()
    }
    
    private var currentMove: Int = 0
    private var weatherCombined: WeatherCombined?
    
    var woeid: Int? {
        didSet {
            fetchData(woeid!)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private func updateButtons(_ move: Int) {
        self.currentMove += move
        if self.currentMove <= 0 {
            self.currentMove = 0
            self.prevButton.isEnabled = false
            self.nextButton.isEnabled = true
        }
        else if self.currentMove >= 5 {
            self.currentMove = 5
            self.prevButton.isEnabled = true
            self.nextButton.isEnabled = false
        }
        else {
            self.prevButton.isEnabled = true
            self.nextButton.isEnabled = true
        }
    }
    
    private func getUrl(_ woeid: Int) -> URL {
        return URL(string: "https://www.metaweather.com/api/location/\(woeid)/")!
    }
        
    private func fetchData(_ woeid: Int) {
        URLSession.shared.dataTask(with: getUrl(woeid)) { (data, response, error) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let weatherCombined = try decoder.decode(WeatherCombined.self, from: data)

                self.weatherCombined = weatherCombined
                DispatchQueue.main.async {
                    self.updateView()
                }
            } catch let err {
                print("Error while parsing", err)
            }
        }.resume()
    }
    
    private func updateView() {
        loadViewIfNeeded()
        if let weatherCombinedUnwrap = self.weatherCombined {
            let weatherData = weatherCombinedUnwrap.consolidated_weather[self.currentMove]

            DispatchQueue.main.async {
                self.weatherStateView.text = weatherData.weather_state_name
                self.currentDateView.text = weatherData.applicable_date
                self.maxTemperatureView.text = "\(String(format: "%.2f", weatherData.max_temp!)) °C"
                self.minTemperatureView.text = "\(String(format: "%.2f", weatherData.min_temp!)) °C"
                self.windSpeedView.text = "\(String(format: "%.2f", weatherData.wind_speed!)) Mph"
                self.windDirectionView.text = "\(String(format: "%.2f", weatherData.wind_direction!)) °"
                self.humidityView.text = "\(weatherData.humidity!) %"
                self.airPressureView.text = "\(String(format: "%.2f", weatherData.air_pressure!)) hPa"
                self.imageView.image = UIImage(named: weatherData.weather_state_abbr!)
                self.navBarView.title = weatherCombinedUnwrap.title
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap" {
            let vc: MapViewController = segue.destination as! MapViewController
            vc.place = self.weatherCombined?.latt_long
       }
    }
}

