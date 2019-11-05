//
//  WeatherCombined.swift
//  Weather App
//
//  Created by Albert Duz on 01/11/2019.
//  Copyright © 2019 Albert Duz. All rights reserved.
//

import Foundation

struct WeatherData: Codable {
    let weather_state_name: String?
    let applicable_date: String?
    let max_temp: Double?
    let min_temp: Double?
    let the_temp: Double?
    let wind_speed: Double?
    let wind_direction: Double?
    let humidity: Int?
    let air_pressure: Double?
    let weather_state_abbr: String?
}

struct WeatherCombined: Codable {
    let consolidated_weather: [WeatherData]
    let title: String?
}

struct City: Codable {
    let title: String?
    let woeid: Int?
}
