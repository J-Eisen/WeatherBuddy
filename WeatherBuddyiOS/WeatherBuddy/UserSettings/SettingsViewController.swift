//
//  SettingsViewController.swift
//  WeatherBuddy
//
//  Created by Jonah Eisenstock on 2/23/18.
//  Copyright © 2018 JonahEisenstock. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource {
    
    //MARK: Settings Variables
    //MARK: Interfaces
    @IBOutlet weak var calendarSwitch: UISwitch!
    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var zipcodeTextField: UITextField!
    //MARK: TableView
    @IBOutlet weak var calendarTableView: UITableView!
    @IBOutlet weak var calendarSuperview: UIScrollView!
    //MARK: Labels
    @IBOutlet weak var locationValue: UILabel!
    @IBOutlet weak var zipcodeValue: UILabel!
    //MARK: -
    //MARK: Variables
    //Mark: Table Variables
    var rows: Int = 0
    var names: [String] = []
    var colors: [UIColor] = []
    //MARK: Global Variables
    var zipCode: Int = 10017
    var defaultZip: Int = 10017
    // Integer passed to LocationData Class
    var locationSwitches: Int = 0 // 0: Calendars On 1: GPS On
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationValue.text = "\(zipCode)"
       if calendarSwitch.isOn {
            let barHeight = UIApplication.shared.statusBarFrame.size.height
            let displayWidth: CGFloat = self.view.frame.width
            let displayHeight: CGFloat = self.view.frame.height
            calendarTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        //FIXME: "Fatal Error: Unexpected nil"
            calendarTableView.dataSource = self
            locationSwitches = 0
        }
       else {
            calendarTableView.isHidden = true
            if locationSwitch.isOn {
                locationValue.isHidden = false
                locationSwitches = 1
            }
            else {
                locationValue.isHidden = true
                locationSwitches = 2
            }
        }
    }
    @IBAction func activateCalendarTable(_ sender: UISwitch) {
        if sender.isOn {
            calendarTableView.isHidden = false
        }
        else {
            calendarTableView.isHidden = true
        }
    }
    
    @IBAction func activateLocation(_ sender: UISwitch) {
        if sender.isOn {
            locationValue.isHidden = false
        }
        else {
            locationValue.isHidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: -
    //MARK: tableView Functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellReuseIdentifier") as! CalendarTableViewCell?
        
        cell?.color = colors[indexPath.row]
        cell?.calendarName?.text = names[indexPath.row]
        
        return cell!
    }
    
    /*
    // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
