//
//  Service.swift
//  FinalProject
//
//  Created by HuangSai on 2022-08-16.
//  Copyright © 2022 EirianTa. All rights reserved.
//
// Sample Weather Url (using both city name and country code to get the weather in case different countries have the same city name):
// https://api.openweathermap.org/data/2.5/weather?q=toronto,ca&appid=382d034fa1b0eb4945f27d5188345b3b

// Sample AutoComplete Url: (can't use https for this auto complete)
// http://gd.geobytes.com/AutoCompleteCity?callback=?&q=tor

// Sample Image Url:
// https://openweathermap.org/img/wn/10d@2x.png

import Foundation

class Service {
    private init() {}
    static let shared = Service() // Singleton

    // API Key
    static let apiKey = "382d034fa1b0eb4945f27d5188345b3b"
    
    enum Endpoints {
        static let weatherBaseURL = "https://api.openweathermap.org/data/2.5/weather"
        static let weatherCityParam = "?q="
        static let weatherAPIKeyParam = "&appid=\(apiKey)"
        static let autoCompleteBaseURL = "http://gd.geobytes.com/AutoCompleteCity"
        static let autoCompleteQueryParam = "?callback=?&q="
        
        case getCity(String)
        case getCityWeather(String)
        
        var stringValue: String {
            switch self {
            case .getCity(let query):
                // Allow adding spaces in the query and replace them by percentage in url
                return Service.Endpoints.autoCompleteBaseURL + Service.Endpoints.autoCompleteQueryParam + (query.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed) ?? "")

            case .getCityWeather(let cityAndCountryCode):
                // Allow adding spaces and replace with percentage in url
                return Service.Endpoints.weatherBaseURL + Service.Endpoints.weatherCityParam + (cityAndCountryCode.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") + Service.Endpoints.weatherAPIKeyParam
            }
        }
        
        var url: URL {
            return URL(string: self.stringValue)!
        }
    }
    
    
    // This function returns a task of fetching data, performed in a URL session.
    // The function is to be used in InitialViewController to fetch a ResponseType Object which is a CityWeatherResponseObj
    @discardableResult class func searchForCityWeather<ResponseType: Decodable>(url: URL, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        
        //print("Getting data from this url: ", url)
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                //print("data: ", String(data: data, encoding: .utf8)!)
                // Convert data to the ResponseType Object which is a CityWeatherResopnseObj
                let response = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(response, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        return task
    }
    
    
    // This function returns a task of fetching data, performed in a URL session.
    // The function is to be used in SearchViewController to fetch an array of strings which are suggestions for the keyword entered in searchBar. 
    class func searchForCity(url: URL, completion: @escaping ([String]?, Error?) -> Void) -> URLSessionTask {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion([], error)
                }
                return
            }

            // Convert Data type to String
            let stringData = String(data: data, encoding: .utf8)
            
            // Sample stringData got back: ?(["Torbert, LA, United States","Torch, OH, United States","Toreboda, VG, Sweden"]);
            // Need to drop 2 letters at the beginning and the end of the stringData in order to get the array string
            let formatedDataString = stringData?.dropFirst(2).dropLast(2)
                       
            // Covert the array string to an array of strings
            if let convertedData = formatedDataString?.data(using: .utf8) {
                do {
                    let response = try JSONSerialization.jsonObject(with: convertedData, options: []) as? [String]
                    
                        DispatchQueue.main.async {
                            completion(response, nil)
                        }
                    }
                catch {
                    DispatchQueue.main.async {
                        completion([], error)
                    }
                }
            }
        }
        task.resume()
        return task
    }
    
    
}
