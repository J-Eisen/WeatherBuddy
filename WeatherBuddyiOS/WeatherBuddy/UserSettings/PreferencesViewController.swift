//
//  PreferencesViewController.swift
//  WeatherBuddy
//
//  Created by Jonah Eisenstock on 2/23/18.
//  Copyright © 2018 JonahEisenstock. All rights reserved.
//
//TODO: Set values at start
import UIKit

class PreferencesViewController: UIViewController {
    
    //MARK: Preference Variables
    var maxTemp, minTemp, precipitation: Int!
    var tempSliderMax: Float = 100
    var tempSliderMin: Float = -10
    var rain, snow: Double!
    var stepperMax: Double = 6
    let stepperMin: Double = 0
    var stepperStep: Double = 0.1
    // Temperature Type
    // 0 = ºF
    // 1 = ºC
    // 2 = K
    var temperatureType: Int!
    // Measure System
    // 0 = Imperial/English
    // 1 = Metric
    var measureSystem: Int!
    
    // MARK: -
    // MARK: Value Interfaces
    // Sliders
    @IBOutlet weak var maxTempSlider: UISlider!
    @IBOutlet weak var minTempSlider: UISlider!
    @IBOutlet weak var precipitationSlider: UISlider!
    // Steppers
    @IBOutlet weak var rainStepper: UIStepper!
    @IBOutlet weak var snowStepper: UIStepper!
    // MARK: Value Labels
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var rainLabel: UILabel!
    @IBOutlet weak var snowLabel: UILabel!
    @IBOutlet weak var precipitationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: -
        // MARK: Initializing View
        initTempSliders()
        initSteppers()
        precipitationSlider.value = Float(precipitation)
        precipitationLabel.text = "\(precipitation)%"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? ViewController {
            viewController.buddy.dataTriggers[0] = Float(maxTemp)
            viewController.buddy.dataTriggers[1] = Float(minTemp)
            viewController.buddy.dataTriggers[2] = Float(rain)
            viewController.buddy.dataTriggers[3] = Float(snow)
            viewController.buddy.dataTriggers[4] = Float(precipitation)
            viewController.buddy.temperatureType = temperatureType
            viewController.buddy.measureSystem = measureSystem
        }
        else {
            let viewController = RootViewController
            viewController.buddy.dataTriggers[0] = Float(maxTemp)
            viewController.buddy.dataTriggers[1] = Float(minTemp)
            viewController.buddy.dataTriggers[2] = Float(rain)
            viewController.buddy.dataTriggers[3] = Float(snow)
            viewController.buddy.dataTriggers[4] = Float(precipitation)
            viewController.buddy.temperatureType = temperatureType
            viewController.buddy.measureSystem = measureSystem
        }
    }
    
    // MARK: -
    // MARK: Functions
    // MARK: Slider Functions
    @IBAction func maxTempSlider(_ sender: UISlider) {
        if Float(minTemp) > sender.value{
            minTempSlider.value = sender.value
            minTemp = Int(sender.value)
        }
        maxTemp = Int(sender.value)
        drawTemp()
    }
    @IBAction func minTempSlider(_ sender: UISlider) {
        if Float(maxTemp) < sender.value{
            maxTempSlider.value = sender.value
            maxTemp = Int(sender.value)
        }
        minTemp = Int(sender.value)
        drawTemp()
    }
    @IBAction func precipitationSlider(_ sender: UISlider) {
        precipitation = Int(sender.value)
        precipitationLabel.text = "\(precipitation)%"
    }
    //MARK: Stepper Functions
    @IBAction func rainStepper(_ sender: UIStepper) {
        if sender.value < stepperStep {
            rain = 0
        }
        else {
            rain = sender.value
        }
        drawRain()
    }
    @IBAction func snowStepper(_ sender: UIStepper) {
        snow = sender.value
        drawSnow()
    }
    //MARK: Segmented Controls
    //MARK: Choosing between Imperial/English & Metric
    @IBAction func measureSystem(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            stepperMax = Double(stepperMax/2.54)
            rain = rain/2.54
            snow = snow/2.54
            stepperStep = 0.1
            measureSystem = sender.selectedSegmentIndex
            initSteppers()
        }
        else {
            stepperMax = Double(stepperMax*2.54)
            stepperStep = 0.5
            rain = rain*2.54
            snow = snow*2.54
            measureSystem = sender.selectedSegmentIndex
            initSteppers()
        }
    }
    //MARK: Choosing between ºF, ºC, K
    @IBAction func temperatureType(_ sender: UISegmentedControl) {
        /* TO: Fahrenheit */
        if sender.selectedSegmentIndex == 0 {
            /* FROM: Celsius */
            if temperatureType == 1 {
               maxTemp = Int(Double(maxTemp)*1.8+32)
               minTemp = Int(Double(minTemp)*1.8+32)
            }
            /* FROM: Kelvin */
            else if temperatureType == 2 {
                maxTemp = Int(1.8*(Double(maxTemp)-273)+32)
                minTemp = Int(1.8*(Double(minTemp)-273)+32)
            }
            temperatureType = sender.selectedSegmentIndex
            tempSliderMax = 100
            tempSliderMin = -10
            maxTemp = checkTemp(tempMin: Int(tempSliderMin), tempMax: Int(tempSliderMax), temp: maxTemp)
            minTemp = checkTemp(tempMin: Int(tempSliderMin), tempMax: Int(tempSliderMax), temp: minTemp)
            initTempSliders()
        }
            /* TO: Celsius */
        else if sender.selectedSegmentIndex == 1 {
            /* FROM: Fahrenheit */
            if temperatureType == 0 {
                maxTemp = Int((Double(maxTemp)-32)*5/9)
                minTemp = Int((Double(minTemp)-32)*5/9)
            }
            /* FROM: Kelvin */
            else if temperatureType == 2 {
                maxTemp = maxTemp - 273
                minTemp = minTemp - 273
            }
            temperatureType = sender.selectedSegmentIndex
            tempSliderMax = 40
            tempSliderMin = -20
            maxTemp = checkTemp(tempMin: Int(tempSliderMin), tempMax: Int(tempSliderMax), temp: maxTemp)
            minTemp = checkTemp(tempMin: Int(tempSliderMin), tempMax: Int(tempSliderMax), temp: minTemp)
            initTempSliders()
        }
            /* TO: Kelvin */
        else {
            /* FROM: Fahrenheit */
            if temperatureType == 0 {
                maxTemp = Int((Double(maxTemp)-32)*5/9+273)
                minTemp = Int((Double(minTemp)-32)*5/9+273)
            }
                /* FROM: Celsius */
            else if temperatureType == 1 {
                maxTemp = maxTemp + Int(273)
                minTemp = minTemp + Int(273)
            }
            tempSliderMax = 310
            tempSliderMin = 250
            maxTemp = checkTemp(tempMin: Int(tempSliderMin), tempMax: Int(tempSliderMax), temp: maxTemp)
            minTemp = checkTemp(tempMin: Int(tempSliderMin), tempMax: Int(tempSliderMax), temp: minTemp)
            temperatureType = sender.selectedSegmentIndex
            initTempSliders()
        }
    }
    // MARK: -
    // MARK: Other Functions
    // MARK: Initializing Sliders
    func initTempSliders(){
        maxTempSlider.minimumValue = tempSliderMin
        maxTempSlider.maximumValue = tempSliderMax
        minTempSlider.minimumValue = tempSliderMin
        minTempSlider.maximumValue = tempSliderMax
        maxTempSlider.value = Float(maxTemp)
        minTempSlider.value = Float(minTemp)
        drawTemp()
    }
    // MARK: Initializing Steppers
    func initSteppers(){
        rainStepper.maximumValue = stepperMax
        rainStepper.minimumValue = stepperMin
        rainStepper.stepValue = stepperStep
        rainStepper.value = rain
        snowStepper.maximumValue = stepperMax
        snowStepper.minimumValue = stepperMin
        snowStepper.stepValue = stepperStep
        snowStepper.value = snow
        drawRain()
        drawSnow()
    }
    //MARK: Updating Labels
    //MARK: Updating Temperature Labels
    func drawTemp(){
        if temperatureType == 2 {
            maxTempLabel.text = "\(maxTemp)"
            minTempLabel.text = "\(minTemp)"
        }
        else {
            maxTempLabel.text = "\(maxTemp)º"
            minTempLabel.text = "\(minTemp)º"
        }
    }
    //MARK: Updating Rain Label
    func drawRain(){
        if measureSystem == 0 {
            rainLabel.text = "\(rain)\""
        }
        else {
            rainLabel.text = "\(rain) cm"
        }
    }
    //MARK: Updating Snow Label
    func drawSnow(){
        if measureSystem == 0 {
            snowLabel.text = "\(snow)\""
        }
        else {
            snowLabel.text = "\(snow) cm"
        }
    }
    //MARK: Checking for Valid Values
    func checkTemp(tempMin: Int, tempMax: Int, temp: Int) -> Int{
        if temp < tempMin {
            return tempMin
        }
        else if temp > tempMax {
            return tempMax
        }
        else {
            return temp
        }
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
