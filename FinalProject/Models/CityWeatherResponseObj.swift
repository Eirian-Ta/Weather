//
//  CityResponseObj.swift
//  FinalProject
//
//  Created by HuangSai on 2022-08-16.
//  Copyright © 2022 EirianTa. All rights reserved.
//

// Sample of response object
/*{
    "coord": {
        "lon": -79.4163,
        "lat": 43.7001
    },
    "weather": [{
        "id": 800,
        "main": "Clear",
        "description": "clear sky",
        "icon": "01d"
    }],
    "base": "stations",
    "main": {
        "temp": 298.01,
        "feels_like": 297.91,
        "temp_min": 295.42,
        "temp_max": 300.21,
        "pressure": 1017,
        "humidity": 52
    },
    "visibility": 10000,
    "wind": {
        "speed": 2.57,
        "deg": 170
    },
    "clouds": {
        "all": 0
    },
    "dt": 1660685187,
    "sys": {
        "type": 2,
        "id": 2043365,
        "country": "CA",
        "sunrise": 1660645403,
        "sunset": 1660695646
    },
    "timezone": -14400,
    "id": 6167865,
    "name": "Toronto",
    "cod": 200
}*/

import Foundation

// Define the response object
struct CityWeatherResponseObj: Codable {
    let weather: [Weather]
    let main: Main
    let name: String
}

// Define the Weather
struct Weather: Codable {
    let icon: String
}

// Define the Main
struct Main: Codable {
    let temp: Double
    let feelsLike: Double // just place here for the next version of the app so that I can work on later for some improvements
    
    // Map the keys in json with the properties
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
    }
    
}
