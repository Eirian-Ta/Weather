//
//  InitialViewController.swift
//  FinalProject
//
//  Created by HuangSai on 2022-08-16.
//  Copyright © 2022 EirianTa. All rights reserved.
//

import UIKit
import CoreData

class InitialViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var cityList: [City] = [] // List of cities fetched from database (city name, country code)
    var cityWeatherDisplays: [CityWeatherDisplayObj] = [] // List of objects used for tableView displaying (city name, temperature, icon)
    var processingCity: String = ""
    var currentSearchTask: URLSessionTask? // Reference to the returned URLSession Task from Service.searchForCity
    
    // Get the list of saved cities from the database
    func getSavedCities(filteringKeyWord : String) {
        let myRequest : NSFetchRequest<City> = City.fetchRequest()
        
        // Use a predicate to filter the list of cities
        let pred = (filteringKeyWord == "" ? nil : NSPredicate(format: "name CONTAINS[cd] %@", filteringKeyWord))
        myRequest.predicate = pred
        
        self.cityList = try! appDelegate.persistentContainer.viewContext.fetch(myRequest)
        
        /*print(cityList.count)
        for city in cityList {
            print(city.country!);
            print(city.name!);
        }*/
    }
    
    // Fetch the weather for each city from the cityList
    func fetchWeatherForCityList() {
        cityWeatherDisplays.removeAll()
        
        for city in self.cityList {
            processingCity = city.name ?? ""
            
            // Using both city name and country code to get the weather in case different countries have the same city name
            let cityAndCountryCode = (city.country?.count == 2 ? (city.name ?? "") + "," + (city.country ?? "") : city.name) ?? ""
            Service.searchForCityWeather(url: Service.Endpoints.getCityWeather(cityAndCountryCode).url, response: CityWeatherResponseObj.self, completion: handleCityWeatherResponse(response:error:))
        }
    }
    
   // Handle Completion
    func handleCityWeatherResponse(response: Decodable?, error: Error?) {
        guard let response = response as? CityWeatherResponseObj else {
            // If the response still returns an error object, but that error object can't be casted into a CityWeatherResponseObj, we still want to show the city that user wants to save, but with "N/A" for weather info
            cityWeatherDisplays.append(CityWeatherDisplayObj(name: processingCity, temp: 999, iconName: ""))
            print(error!)
                return
        }
                   
        // Add the weather fetched for each city into an array used for display
        cityWeatherDisplays.append(CityWeatherDisplayObj(name: response.name, temp: response.main.temp, iconName: response.weather[0].icon))
        print("Total of city: ", cityWeatherDisplays.count)
        if (cityList.count == cityWeatherDisplays.count) {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getSavedCities(filteringKeyWord: "")
        DispatchQueue.main.async {
            self.fetchWeatherForCityList()
        }
        
        /*print("Total of city: ", cityWeatherDisplays.count)
        for city in cityWeatherDisplays {
            print("Temp: ", city.temp)
            print("City: ", city.name)
        }*/
    }
}



// MARK: Extension for TableViewDelegate and TableViewDataSource
extension InitialViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityWeatherDisplays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let imgBaseUrl = "https://openweathermap.org/img/wn/"
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
        let city = cityWeatherDisplays[indexPath.row]

        cell.accessoryType = .disclosureIndicator // add the arrow at the end of each row
        cell.textLabel?.text = city.name
        cell.detailTextLabel?.text = (city.temp == 999 ? "N/A" : String(format: "%.1f", city.temp))
        if (city.iconName != "") {
            if let myUrl = URL(string: imgBaseUrl + city.iconName + "@2x.png") {
               let myQ = DispatchQueue(label: "Getting Img")
               myQ.async {
                   if let myImgData = try? Data(contentsOf: myUrl){
                       DispatchQueue.main.async {
                        cell.imageView?.image = UIImage(data: myImgData)
                       }
                   }
               }
           }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            //print("Removing index: ", indexPath.row)
            cityWeatherDisplays.remove(at: indexPath.row)
            tableView.reloadData()
            appDelegate.persistentContainer.viewContext.delete(cityList[indexPath.row])
            appDelegate.saveContext()

        default:
            ()
        }
    }
    
    // Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "search" {
            //print("directing to search")
        } else if segue.identifier == "details" {
            //print("directing to details")
            let detailsVC = segue.destination as? DetailsViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                detailsVC?.selectedRowIndex = indexPath.row
            }
        }
    }
}

// MARK: Extension for SearchBarDelegate
extension InitialViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //print("Looking for: ", searchText)
        getSavedCities(filteringKeyWord: searchText)
        fetchWeatherForCityList()
        tableView.reloadData()
    }
    
}
