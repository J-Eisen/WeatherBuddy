//
//  WeatherData.swift
//  WeatherBuddy
//
//  Created by Jonah Eisenstock on 2/5/18.
//  Copyright © 2018 JonahEisenstock. All rights reserved.
//

// TODO: Make WeatherData into Singleton? Or part of Buddy

import Foundation
import UIKit

final class WeatherData {
    
    //MARK:-
    //MARK: Class for weatherData
    class weatherJsonData: Decodable {
        let hour, feelsLikeEnglish, feelsLikeMetric, rainMetric, snowMetric, precipitation: Int?
        let rainEnglish, snowEnglish: Float?
        var location: Int?
        
        final func setLocation(location: Int){
            self.location = location
        }
        
        //MARK: Coding Keys
        final class HourlyForecast: Codable {
            enum codingKeys: String, CodingKey {
                case FCTTIME
                case hour
                case feelsLike = "feelslike"
                case rain = "qpf"
                case snow
                case precipitation = "pop"
            }
            
            enum FCTTimeCodingKeys: String, CodingKey {
                case hour
            }
            enum FeelsLikeCodingKeys: String, CodingKey {
                case feelsLikeEnglish = "english"
                case feelsLikeMetric = "metric"
            }
            enum RainCodingKeys: String, CodingKey {
                case rainEnglish = "english"
                case rainMetric = "metric"
            }
            enum SnowCodingKeys: String, CodingKey {
                case snowEnglish = "english"
                case snowMetric = "metric"
            }
            
            //MARK: Decoding into float or int
            required init (from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: codingKeys.self)
                
                let FCTTIME = try container.nestedContainer(keyedBy: FCTTimeCodingKeys.self, forKey: .FCTTIME)
                let hour:Int? = Int(try FCTTIME.decode(String.self, forKey: .hour))
                
                let feelsLike = try container.nestedContainer(keyedBy: FeelsLikeCodingKeys.self, forKey: .feelsLike)
                let feelsLikeEnglish:Int? = Int(try feelsLike.decode(String.self, forKey: .feelsLikeEnglish))
                let feelsLikeMetric:Int? = Int(try feelsLike.decode(String.self, forKey: .feelsLikeMetric))
                
                let rain = try container.nestedContainer(keyedBy: RainCodingKeys.self, forKey: .rain)
                let rainEnglish:Float? = Float(try rain.decode(String.self, forKey: .rainEnglish))
                let rainMetric:Int? = Int (try rain.decode(String.self, forKey: .rainMetric))
                
                let snow = try container.nestedContainer(keyedBy: SnowCodingKeys.self, forKey: .snow)
                let snowEnglish:Float? = Float (try snow.decode(String.self, forKey: .snowEnglish))
                let snowMetric:Int? = Int (try snow.decode(String.self, forKey: .snowMetric))
                
                let precipitation:Int? = Int (try container.decode(String.self, forKey: .precipitation))
            }
        }
    }
    
    var rawWeatherList = [weatherJsonData]()
    var weatherList = [weatherJsonData]()
    let locationData = LocationData()

    //MARK: -
    //MARK: Get Weather Data
    func fetchWeatherData(locations: [Int]) -> [weatherJsonData] {
    
    //MARK: Get JSON data from WUnderground
    
    // Set Up the Session
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)
    
    // Data Request
        for location in locations {
            let urlString:String = "http://api.wunderground.com/api/fb2d4e978c2c2a11/hourly/q/\(location).json"
            let url = URL(string: urlString)!
    
            session.dataTask(with: URLRequest(url: url)) {
                (data, response, error) in
                
                // Check for errors
                guard error == nil else {
                    print(error!)
                    return
                }
                // Check that we got data
                guard let responseData = data else {
                    print("Error: Data not recieved")
                    return
                }
                
                // Parse as JSON
                do {
                    let decoder = JSONDecoder()
                    let weatherInstanceData = try decoder.decode(weatherJsonData.self, from: responseData)
                    weatherInstanceData.setLocation(location: location)
                    // Add to weatherList
                    self.rawWeatherList.append(weatherInstanceData)
                } catch {
                    print("Error converting data to JSON")
                }
            } .resume()
        }
        return weatherList
    }
}
