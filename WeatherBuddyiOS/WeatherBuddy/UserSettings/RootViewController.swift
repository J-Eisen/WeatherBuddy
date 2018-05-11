//
//  RootViewController.swift
//  WeatherBuddy
//
//  Created by Jonah Eisenstock on 2/23/18.
//  Copyright © 2018 JonahEisenstock. All rights reserved.
//
//TODO: Title for settings
import UIKit

class RootViewController: UIViewController {
    
    private var preferencesViewController: PreferencesViewController!
    private var settingsViewController: SettingsViewController!
    
    var buddy = BuddyData.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preferencesViewController =
            storyboard?.instantiateViewController(withIdentifier: "Preferences")
            as! PreferencesViewController
        preferencesViewController.view.frame = view.frame
        switchViewController(from: nil, to: preferencesViewController) // Helper method

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        if preferencesViewController != nil
            && preferencesViewController!.view.superview == nil {
            preferencesViewController = nil
        }
        if settingsViewController != nil
            && settingsViewController!.view.superview == nil {
            settingsViewController = nil
        }
    }
    
    private func switchViewController(from fromVC: UIViewController?,
                                      to toVC: UIViewController?) {
        if fromVC != nil {
            fromVC!.willMove(toParentViewController: nil)
            fromVC!.view.removeFromSuperview()
            fromVC!.removeFromParentViewController()
            
            if fromVC == preferencesViewController {
                buddy.dataTriggers[0] = Float(preferencesViewController.maxTemp)
                buddy.dataTriggers[1] = Float(preferencesViewController.minTemp)
                buddy.dataTriggers[2] = Float(preferencesViewController.rain)
                buddy.dataTriggers[3] = Float(preferencesViewController.snow)
                buddy.dataTriggers[4] = Float(preferencesViewController.precipitation)
                buddy.temperatureType = preferencesViewController.temperatureType
                buddy.measureSystem = preferencesViewController.measureSystem
            }
            else {
                //FIXME: Add a way to edit userZipcode
                //                buddy.locationData.userZipcode = settingsViewController.defaultZip
                buddy.calendarOn = settingsViewController.calendarSwitch.isOn
                buddy.locationOn = settingsViewController.locationSwitch.isOn
            }
        }
        if toVC != nil {
            self.addChildViewController(toVC!)
            self.view.insertSubview(toVC!.view, at: 0)
            toVC!.didMove(toParentViewController: self)
        
            if toVC == preferencesViewController {
                preferencesViewController.maxTemp = Int(buddy.dataTriggers[0])
                preferencesViewController.minTemp = Int(buddy.dataTriggers[1])
                preferencesViewController.rain = Double(buddy.dataTriggers[2])
                preferencesViewController.snow = Double(buddy.dataTriggers[3])
                preferencesViewController.precipitation = Int(buddy.dataTriggers[4])
                preferencesViewController.temperatureType = buddy.temperatureType
                preferencesViewController.measureSystem = buddy.measureSystem
            }
            else {
                //FIXME: add a way to edit userZipcode
                //                settingsViewController.defaultZip = buddy.defaultZipcode
                settingsViewController.calendarSwitch.isOn = buddy.calendarOn
                settingsViewController.locationSwitch.isOn = buddy.locationOn
                settingsViewController.rows = buddy.getCalendarRows()
                settingsViewController.colors = buddy.getCalendarColors()
                settingsViewController.names = buddy.getCalendarNames()
            }
        }
    }
    
    @IBAction func switchViews(sender: UISegmentedControl){
        if sender.selectedSegmentIndex == 0 {
            if preferencesViewController == nil {
                preferencesViewController =
                storyboard?.instantiateViewController(withIdentifier: "Preferences")
                as! PreferencesViewController
            }
        }
        else {
            if settingsViewController == nil {
                settingsViewController =
                storyboard?.instantiateViewController(withIdentifier: "Settings")
                as! SettingsViewController
            }
        }
        
        UIView.beginAnimations("View Flip", context: nil)
        UIView.setAnimationDuration(0.4)
        UIView.setAnimationCurve(.easeInOut)
        
        // Switch the Views
        if preferencesViewController != nil
            && preferencesViewController!.view.superview != nil {
            UIView.setAnimationTransition(.flipFromLeft, for: view, cache: true)
            settingsViewController.view.frame = view.frame
            switchViewController(from: preferencesViewController,
                                 to: settingsViewController)
        } else {
            UIView.setAnimationTransition(.flipFromRight, for: view, cache: true)
            preferencesViewController.view.frame = view.frame
            switchViewController(from: settingsViewController, to: preferencesViewController)
        }
        UIView.commitAnimations()
    }
    
    // Pass info back to main ViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
//        if let viewController = segue.destination as? ViewController {
//        }
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
