//
//  WeatherManager.swift
//  Clima
//
//  Created by Abdulrhman on 13/05/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManger:WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}


struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=e1014586eb0cb7e790722d74a53bf396&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName:String)  {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        
        //1. creat a URL
        if let url = URL(string: urlString){
            
        // 2. Create a URLSession
            let session = URLSession(configuration: .default)
            
        // 3. Give the sessiona task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData){
                        
                        self.delegate?.didUpdateWeather(self, weather:weather)
                    }
                }
            }
            
        // 4. Start the task
            task.resume()
            
        }
    }
    
    func parseJSON(_ weatherData: Data)-> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let idWeather = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            print(idWeather,temp,name)
            
            let weather = WeatherModel(conditionId: idWeather, cityName: name, temperature: temp)
            return weather
            
            
        } catch{
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
}

