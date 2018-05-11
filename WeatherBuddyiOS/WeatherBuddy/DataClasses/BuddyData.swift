//
//  BuddyData.swift
//  WeatherBuddy
//
//  Created by Jonah Eisenstock on 2/10/18.
//  Copyright © 2018 JonahEisenstock. All rights reserved.
//

import Foundation
import UIKit

//TODO: Make Buddy the hub of all Data Types

final class BuddyData {
    static let sharedInstance = BuddyData()
    
    //MARK:-
    //MARK: Buddy Variables
    
    var temperatureType: Int = 0 // 0 = Fahrenheit, 1 = Celcius, 2 = Kelvin
    var measureSystem: Int = 0 // 0 = Imperial/English, 1 = Metric
    var calendarOn = true
    var locationOn = true
    let weatherData = WeatherData()
    let locationData = LocationData()
    //  TODO: Delete?
    //    var zipcodes: [Int] = []
    //    var zipcode: Int?
    
    //MARK: Buddy arrays
    
    // Item List
    // Shorts:      0
    // Light Coat:  1
    // Heavy Coat:  2
    // Rain Boots:  3
    // Snow Boots:  4
    // Umbrella:    5
    // WTF:         6
    var itemNames: [String] = ["Shorts", "Light Coat", "Heavy Coat", "Rain Boots", "Snow Boots", "Umbrella", "WTF"]
    var itemBools: [Bool] = [false, false, false, false, false, false, false]
    
    // Trigger List
    // Shorts (MaxTemp):    0
    // Heavy Coat (MinTemp): 1
    // Rain Boots (Rain):    2
    // Snow Boots (Snow):    3
    // Umbrella (Percip):    4
    var dataTriggers: [Float] = [80, 40, 1, 1, 60]
    
    // Data List
    // highTemp: 0
    // lowTemp:  1
    // rain:     2
    // snow:     3
    // percip:   4
    var dataEnglish: [Float] = [0,0,0,0,0]
    var dataMetric: [Int] = [0,0,0,0,0]
    
    private init() {}
    
    //MARK:-
    //MARK: Methods
    
    final func fetchData(){
        setLocationAccess()
        let userLocations = locationData.locateUser()
        var userWeather = weatherData.fetchWeatherData(locations: userLocations)
        if calendarOn {
            let userEvents = locationData.getEventList()
            userWeather = getArrays(eventList: userEvents, rawWeatherList: userWeather)
        }
        updateArrays(weatherList: userWeather)
    }
    
    //Mark: Getting weatherData
    final func getArrays(eventList: [LocationData.calendarEvent], rawWeatherList: [WeatherData.weatherJsonData]) -> [WeatherData.weatherJsonData]{
        var weatherList: [WeatherData.weatherJsonData] = []
        var index: Int = 0
        
        while index < (eventList.count) - 1 {
            let t1 = eventList[index].endTime
            let l1 = eventList[index].location!
            let t2 = eventList[index+1].startTime
            let l2 = eventList[index+1].location!
            for weather in rawWeatherList {
                guard weather.hour! < (t2 + 1) else { break }
                if t1 - 1 >= weather.hour! && weather.hour! <= t2
                    && weather.location! == l1 {
                    weatherList.append(weather)
                }
                else if t1 <= weather.hour! && weather.hour! <= t2 + 1
                    && weather.location! == l2 {
                    weatherList.append(weather)
                }
            }
            index += 1
        }
        return weatherList
    }
    
    //MARK: Checking temperature
    private final func checkTemp(dataSet: [Float]){
        if (dataTriggers[0] <= dataSet[1]){
            itemBools[0] = true
            itemBools[1] = false
            itemBools[2] = false
        }
        else if (dataTriggers[1] >= dataSet[0]){
            itemBools[0] = false
            itemBools[1] = false
            itemBools[2] = true
        }
        else if (dataTriggers[0] > dataSet[0]
            && dataTriggers[1] < dataSet[1]){
            itemBools[0] = false
            itemBools[1] = true
            itemBools[2] = false
        }
        else if (dataTriggers[0] < dataSet[0]
            && dataTriggers[1] < dataSet[1]){
            itemBools[0] = true
            itemBools[1] = true
            itemBools[2] = false
        }
        else if (dataTriggers[0] > dataSet[0]
            && dataTriggers[1] > dataSet[1]){
            itemBools[0] = false
            itemBools[1] = true
            itemBools[2] = true
        }
        else {
            itemBools[0] = false
            itemBools[1] = false
            itemBools[2] = false
            itemBools[6] = true
        }
    }
    
    //MARK: Check all method (used below)
    private final func checkAll() {
        var dataSet: [Float] = []
        if measureSystem == 0 {
            dataSet = dataEnglish
            if temperatureType == 1 {
                dataSet[0] = Float(dataMetric[0])
                dataSet[1] = Float(dataMetric[1])
            }
            else if temperatureType == 2 {
                dataSet[0] = Float(dataMetric[0]) + 273.15
                dataSet[1] = Float(dataMetric[1]) + 273.15
            }
        }
        else if measureSystem == 1 {
            switch temperatureType {
            case 0:
                dataSet[0] = dataEnglish[0]
                dataSet[1] = dataEnglish[1]
                break
            case 1:
                dataSet[0] = Float(dataMetric[0])
                dataSet[1] = Float(dataMetric[1])
                break
            case 2:
                dataSet[0] = Float(dataMetric[0]) + 273.15
                dataSet[1] = Float(dataMetric[1]) + 273.15
                break
            default:
                print("Error: Unknown temperature type found")
            }
            for index in 2...4 {
                dataSet[index] = Float(dataMetric[index])
            }
        }
        else {
            print("Error: Unknown measure system found")
        }
        checkTemp(dataSet: dataSet)
        for index in 3...5 {
            if (dataTriggers[index] <= dataSet[index]){
                itemBools[index] = true
            }
            else {
                itemBools[index] = false
            }
        }
    }
    
    //MARK: Updating the [metric] & [english]
    private final func updateArrays(weatherList: [WeatherData.weatherJsonData]) {
            for weather in weatherList {
            
        // Updating FeelsLike English
                if weather.feelsLikeEnglish! > Int(self.dataEnglish[0]){
                    self.dataEnglish[0] = Float(weather.feelsLikeEnglish!)
                }
                else if weather.feelsLikeEnglish! < Int(self.dataEnglish[1]){
                    self.dataEnglish[1] = Float(weather.feelsLikeEnglish!)
                }
        // Updating FeelsLike Metric
                if weather.feelsLikeMetric! > self.dataMetric[0] {
                    self.dataMetric[0] = weather.feelsLikeMetric!
                }
                else if weather.feelsLikeMetric! < self.dataMetric[1]{
                    self.dataMetric[1] = weather.feelsLikeMetric!
                }
        
        // Updating Rain English
                if weather.rainEnglish! > self.dataEnglish[2]{
                    self.dataEnglish[2] = weather.rainEnglish!
                }
        // Updating Rain Metric
                if weather.rainMetric! > self.dataMetric[2]{
                    self.dataMetric[2] = weather.rainMetric!
                }
        
        // Updating Snow English
                if weather.snowEnglish! > self.dataEnglish[3]{
                    self.dataEnglish[3] = weather.snowEnglish!
                }
        // Updating Snow Metric
                if weather.snowMetric! > self.dataMetric[3]{
                    self.dataMetric[3] = weather.snowMetric!
                }
        // Updating Percipitation
                if weather.precipitation! > self.dataMetric[4]{
                    self.dataMetric[4] = weather.precipitation!
                    self.dataEnglish[4] = Float(weather.precipitation!)
                }
                checkAll()
            }
       /* for index in 0...5 {
            if measureSystem == 0 {
                if index < 3 {
                    if !items[index] && index > 0 {
                        if temperatureType == 1 {
                            itemData[index] = Float(dataMetric[index-1])
                        }
                        else if temperatureType == 2 {
                            itemData[index] = Float(dataMetric[index-1]) + 273.15
                        }
                        else {
                            itemData[index] = dataEnglish[index-1]
                        }
                    }
                    else if !items[index] {
                        if temperatureType == 1 {
                            itemData[index] = Float(dataMetric[index+1])
                        }
                        else if temperatureType == 2 {
                            itemData[index] = Float(dataMetric[index+1]) + 273.15
                        }
                        else {
                            itemData[index] = Float(dataEnglish[index+1])
                        }
                    }
                    else {
                        if temperatureType == 1 {
                            itemData[index] = Float(dataMetric[index])
                        }
                        else if temperatureType == 2 {
                            itemData[index] = Float(dataMetric[index]) + 273.15
                        }
                        else {
                            itemData[index] = dataEnglish[index]
                        }
                    }
                }
                else {
                    itemData[index] = dataEnglish[index-1]
                }
            }
            else {
                if index < 3 {
                    if !items[index] && index > 0 {
                        if temperatureType == 0 {
                            itemData[index] = dataEnglish[index-1]
                        }
                        else if temperatureType == 2 {
                            itemData[index] = Float(dataMetric[index-1]) + 273.15
                        }
                        else {
                            itemData[index] = Float(dataMetric[index-1])
                        }
                    }
                    else if !items[index] {
                        if temperatureType == 0 {
                            itemData[index] = dataEnglish[index+1]
                        }
                        else if temperatureType == 2 {
                            itemData[index] = Float(dataMetric[index+1]) + 273.15
                        }
                        else {
                            itemData[index] = Float(dataMetric[index+1])
                        }
                    }
                    else {
                        if temperatureType == 0 {
                            itemData[index] = dataEnglish[index]
                        }
                        else if temperatureType == 2 {
                            itemData[index] = Float(dataMetric[index]) + 273.15
                        }
                        else {
                            itemData[index] = Float(dataMetric[index])
                        }
                    }
                }
                else {
                    itemData[index] = Float(dataMetric[index-1])
                }
            }
        }*/
    }
    
    final func safeReset() {
        weatherData.rawWeatherList = []
    }
    
    //MARK: -
    //MARK: Gets
    //MARK: ...for calendar cells
    final func getCalendarRows() -> Int{
        return locationData.getCalendarRows()
    }
    final func getCalendarNames() -> [String]{
        return locationData.getCalendarNames()
    }
    final func getCalendarColors() -> [UIColor] {
        return locationData.getCalendarColors()
    }
    
    //MARK: -
    //MARK: Sets
    //MARK: ...locationData
    final func setLocationAccess() {
        if calendarOn {
            locationData.setLocationAccess(access: 0)
        }
        else if locationOn && !calendarOn {
            locationData.setLocationAccess(access: 1)
        }
        else {
            locationData.setLocationAccess(access: 2)
        }
    }
}
