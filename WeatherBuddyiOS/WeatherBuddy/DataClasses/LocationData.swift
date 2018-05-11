//
//  LocationData.swift
//  WeatherBuddy
//
//  Created by Jonah Eisenstock on 2/5/18.
//  Copyright © 2018 JonahEisenstock. All rights reserved.
//
//

import UIKit
import EventKit
import EventKitUI

//TODO: Make locationdata into singleton? (Or part of buddy)
//TODO: Cache the geolocation data (Convert to zipcode at the end)
//TODO: Add documentation

final class LocationData {
    static let sharedInstance = LocationData()
//    private init() {}
//MARK: -
//MARK: Global variables
    //TODO: Remove as many variables from here as possible
    
    final private let DefaultLocation = 10017
//    private var locations: [Int] = []   Removed
    private var locationAccess = 0 // Switches 0: allCalendars, 1: GeoLocation
    private lazy var calendarLibrary: [userCalendar] = []
    final let EventStore = EKEventStore()
    private var userZipcode: Int?
//    private var allCalendars: [EKCalendar]? Removed
    private var eventList: [calendarEvent] = []
    private var calendarNames: [String]?
    private var calendarColors: [UIColor]?
    private var calendarRows: Int = 0
    
//  Needed at all?
//    private let formatter = DateFormatter()
//    private let userCalendar = Calendar.current
//    private let calendarComponents : Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
    
//MARK: -
//MARK: Methods
    
//MARK: Get User Location | allCalendars & GPS
    
    final func locateUser() -> [Int] {
        var locations: [Int] = []
        let eventAuthorizationStatus = EKEventStore.authorizationStatus(for: EKEntityType.event)
        let locationAuthorizationStatus = CLLocationManager.authorizationStatus()
        
        switch locationAccess {
        case 0:
            if eventAuthorizationStatus == .notDetermined {
                EventStore.requestAccess(to: EKEntityType.event, completion: {[weak self] authorized,
                    error in
                    if authorized {
                        self?.getLocationByCalendar()
                        self?.retrieveZipcodes()
                    }
                })
                break
            }
            else if eventAuthorizationStatus == .authorized {
                getLocationByCalendar()
                retrieveZipcodes()
                break
            }
            else {
                self.locationAccess = 1
            }
        case 1:
            if locationAuthorizationStatus == .notDetermined {
                //TODO: determine and set up authorization for gps
                break
            }
            else if locationAuthorizationStatus == .authorizedWhenInUse || locationAuthorizationStatus == .authorizedAlways {
                getLocationByGPS()
                break
            }
            else {
                self.locationAccess = 2
            }
        default:
            if userZipcode != nil {
                locations.append(userZipcode!)
            }
            else {
                locations.append(DefaultLocation)
            }
        }
        return locations
    }
    
    final private func getLocationByCalendar(){
        let dates = initDates()
        let allCalendars = EventStore.calendars(for: EKEntityType.event)
        calendarLibrary = setActiveCalendars(allCalendars)
        fetchEvents(calendarLibrary, dates.0, dates.1)
    }
    
    /// Initializes the start and end times for finding events
    /// Start time: Now
    /// End time: 24 hours from now, unless it is earlier than 0600 (6 am)
    final func initDates() -> (Date, Date) {
        let now = Date.init()
        var endDate: Date
    
        let nowCheck: Double = Double(now.timeIntervalSince1970.truncatingRemainder(dividingBy: 3600))
        if (nowCheck > 6){
            let timeChange: Double = 86400 - ((nowCheck - 6) * 3600)
            endDate = Date.init(timeInterval: timeChange, since: now)
        } else {
            endDate = Date.init(timeInterval: 86400, since: now)
        }
    return (now, endDate)
    }
    
    /// Adds new calendars to calendarLibrary
    ///
    /// - Parameter allCalendars: internal variable of all the user's calendars
    /// - Returns: calendarLibrary: updated version of calendarLibrary
    final private func setActiveCalendars(_ allCalendars: [EKCalendar]) -> [userCalendar] {
        if !calendarLibrary.isEmpty {
            for allCal in allCalendars {
                var unused = true
                for cal in calendarLibrary {
                    if cal.calendar!.calendarIdentifier == allCal.calendarIdentifier {
                        unused = false
                    }
                }
                if unused == true {
                    calendarLibrary.append(userCalendar(allCal, true))
                    calendarColors?.append(UIColor.init(cgColor: (allCal.cgColor)))
                    calendarNames?.append(allCal.calendarIdentifier)
                    calendarRows += 1
                }
            }
        }
        else {
            for allCal in allCalendars {
                calendarLibrary.append(userCalendar(allCal, true))
                calendarColors?.append(UIColor.init(cgColor: (allCal.cgColor)))
                calendarNames?.append(allCal.calendarIdentifier)
                calendarRows += 1
            }
        }
        guard calendarLibrary.isEmpty == false else { return []}
        return calendarLibrary
    }
    final private func fetchEvents(_ calendars: [userCalendar],_ date1: Date,_ date2: Date){
        var calendarArray: [EKCalendar] = []
        for cal in calendarLibrary {
            if cal.active! {
                calendarArray.append(cal.calendar!)
            }
        }
        getEventInfo(calendarArray, date1, date2)
    }
    
    final private func getEventInfo(_ allCalendars: [EKCalendar], _ now: Date, _ endDate: Date) {
        let events = EventStore.events(matching: EventStore.predicateForEvents(withStart: now, end: endDate, calendars: allCalendars)).sorted(){
            (e1: EKEvent, e2: EKEvent) -> Bool in
            return e1.startDate.compare(e2.startDate) == ComparisonResult.orderedAscending
        }
        for e in events {
            eventList.append(calendarEvent.init(startTime: Calendar.current.component(.hour, from: e.startDate), endTime: Calendar.current.component(.hour, from: e.endDate), locationString: e.location!))
        }
    }
    
    /// Gets zipcodes from geoLocation data
    /// Note: setZipcode is part of calendarEvent
    /// Try to make sure this is only called when necessary
    ///
    /// - Parameter eventList: list of events user will attend
    final private func retrieveZipcodes() {
        let geocoder = CLGeocoder.self()
        if eventList.count > 0 {
            for e in eventList {
                if e.location == nil {
                    e.setZipcode(geocoder: geocoder, DefaultLocation: DefaultLocation)
                }
            }
        }
    }
    
    final private func updateLocations(eventList: [calendarEvent], locationList: [Int]) -> [Int] {
        var locations = locationList
        var found: Bool
        for e in eventList {
            found = false
            for loc in locations {
                if loc == e.location {
                    found = true
                }
            }
            if !found {
                locations.append(e.location!)
            }
        }
        return locations
    }
    
    
    //FIXME: locationManager delegate not working
    final private func getLocationByGPS() {
        let locationManager = CLLocationManager()
//       locationManager.delegate = ViewController
        
        let authStatus = CLLocationManager.authorizationStatus()
        switch authStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                break
            case .authorizedWhenInUse:
                startLocationTracking(locationManager)
                break
            default:
                print("Error: CLLocationManager authorization status | LocationData")
        }
    }
    
    //FIXME: func locationManager not working
    /*final private func locationManager(_ manager: CLLocationManager, didChangeAuthorization status:
        CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            startLocationTracking()
        }
    }*/
    
    final func startLocationTracking(_ locationManager: CLLocationManager) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    /*   Not used
    final private func getLocationZipcode(_ locationManager: CLLocationManager, didUpdateLocations geoLocations: [CLLocation]) {
        guard let location = geoLocations.last else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: {placemarks, _ in
            guard let placemark = placemarks?.first else { return }
            guard placemark.postalCode != nil else { return }
            self.locations.append(Int(placemark.postalCode!)!)
        })
        locationManager.stopUpdatingLocation()
    }*/

    //MARK: -
    //MARK: Gets
    //MARK: ...for calendar Info
    
    final func getCalendarRows() -> Int {
        return calendarRows
    }
    final func getCalendarNames() -> [String] {
        guard calendarNames != nil else { return []}
        return calendarNames!
    }
    final func getCalendarColors() -> [UIColor] {
        guard calendarColors != nil else { return []}
        return calendarColors!
    }
    
    //MARK: ...for data
    
    final func getEventList() -> [calendarEvent] {
        return eventList
    }
    
    final func getEventList(refiningLocation: [calendarEvent]) -> [calendarEvent] {
        return eventList
    }
    
//    final func getEvents() -> [EKEvent]? {
//        return events
//    }
    
    //MARK: -
    //MARK: Sets
    
    func setLocationAccess(access: Int){
        guard (access >= 0 && access <= 2) else { return }
        locationAccess = access
    }
    
    //MARK: -
    //MARK: Event Storage Class
    final class calendarEvent {
        let startTime, endTime: Int
        var location: Int?
        private let locationString: String
        
        init(startTime: Int, endTime: Int, locationString: String) {
            self.startTime = startTime
            self.endTime = endTime
            self.locationString = locationString
        }
        
        //MARK: locationString -> Geo | Get Zipcode (Int)
        
        final func setZipcode(geocoder: CLGeocoder, DefaultLocation: Int){
            geocoder.geocodeAddressString(locationString, completionHandler: { (placemarks, error) in
                if error == nil {
                    self.location = Int((placemarks?[0].postalCode)!)!
                }
                else {
                    self.location = DefaultLocation
                }
            })
        }
    }
    
    class userCalendar {
        let calendar: EKCalendar?
        var active: Bool?
        
        init(_ calendar: EKCalendar, _ active: Bool) {
            self.calendar = calendar; self.active = active
        }
    }

//MARK: -
//MARK: Closures

//MARK: refineData Closure

// FIXME: Use a closure or protocol to make weatherData and locationData work together

//    let refiningLocation: ([calendarEvent]) -> () -> [calendarEvent] = { events in
//        let sortedList = sortEventList(events: [calendarEvent])
//        return sortedList
//    }
    
    func sortEventList (eventArray: [calendarEvent]) -> [calendarEvent] {
        var array = eventArray
        
        guard (eventArray.count) > 1 else { return eventArray }
        
        func quickSort (array: [calendarEvent]) {
            quickSort(low: 0, high: array.count - 1);
        }
        
        func quickSort (low: Int, high: Int) -> () {
            guard (low < high) else { return }
            let p = partition(low: low, high: high)
            quickSort(low: low, high: p); quickSort(low: p + 1, high: high)
        }
        
        func partition (low: Int, high: Int) -> Int {
            let pivot = array[low]
            var i = low; var j = high
            
            while (i < j) {
                while (array[i].startTime < pivot.startTime) {
                    i += 1
                }
                while (array[j].startTime > pivot.startTime) {
                    j -= 1
                }
                if (i < j) { array.swapAt(i, j)}
            }
            return j
        }
        
        quickSort(array: array)
        return array
    }
}
