//
//  InitialViewController.swift
//  FinalProject
//
//  Created by HuangSai on 2022-08-16.
//  Copyright © 2022 EirianTa. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    var currentSearchTask: URLSessionTask? // Reference to the returned URLSession Task from Service.searchForCity
    var citySuggestions: [String]? // Optional array of strings that holds results returns from AutoComplete
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
        

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
        
    
    // Add the selected city to the context and persist the data
    func addCity(location: String) {
        let city = City(context: appDelegate.persistentContainer.viewContext)
        
        // Sample of location string: "Torbert, LA, United States"
        city.name = location.components(separatedBy: ",")[0]
        print("Country Name: ", location.components(separatedBy: ",")[2]);
        city.country = getCountryCode(for:  location.components(separatedBy: ",")[2].trimingLeadingSpaces())

        appDelegate.saveContext()
             
        // Configure and present the alertVC
        let alertVC = UIAlertController(title: "Successful", message: "\(city.name ?? "") has been added to your list", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            // Redirect back to the previous screen
            self.navigationController?.popViewController(animated: true)
        }
        alertVC.addAction(okAction)
        alertVC.view.layoutIfNeeded()
        present(alertVC, animated: true, completion: nil)
    }
}


// MARK: Extension for UITableViewDelgate UITableDataSource
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citySuggestions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
        
        let city = citySuggestions?[indexPath.row]
        cell.textLabel?.text = city?.components(separatedBy: ",")[0] ?? ""
        
        if let count = city?.count {
            guard count > 2 && cell.textLabel?.text != nil else {
                return cell
            }
            cell.detailTextLabel?.text = city?.components(separatedBy: ",")[2] ?? ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cityName = citySuggestions?[indexPath.row] {
            addCity(location: cityName)
        }
    }
}


// MARK: Extension for SearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // The search requires at least 3 characters to start
        guard searchText.count > 2 else {
            citySuggestions?.removeAll()
            tableView.reloadData()
            return
        }
        
        currentSearchTask = Service.searchForCity(url: Service.Endpoints.getCity(searchText).url, completion: handleSearchCityResponse(citySuggestions:error:))
    }
    
    // Handle completion
    func handleSearchCityResponse(citySuggestions: [String]?, error: Error?) {
        guard error == nil else {
            print(error!)
            return
        }

        self.citySuggestions = citySuggestions
        tableView.reloadData()
    }
}

extension String {
    func trimingLeadingSpaces(using characterSet: CharacterSet = .whitespacesAndNewlines) -> String {
        guard let index = firstIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: characterSet) }) else {
            return self
        }
        return String(self[index...])
    }
}

private func getCountryCode(for fullCountryName : String) -> String {
    //print("Converting full country name: ", fullCountryName)
    let locales : String = ""
    for localeCode in NSLocale.isoCountryCodes {
        let identifier = NSLocale(localeIdentifier: localeCode)
        let countryName = identifier.displayName(forKey: NSLocale.Key.countryCode, value: localeCode)
        if fullCountryName.lowercased() == countryName?.lowercased() {
            //print("Code found!")
            return localeCode
        }
    }
    //print("Returning code: ", locales)
    return locales
}
