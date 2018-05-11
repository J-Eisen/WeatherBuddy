//
//  ViewController.swift
//  WeatherBuddy
//
//  Created by Jonah Eisenstock on 2/12/18.
//  Copyright © 2018 JonahEisenstock. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var buddy = BuddyData.sharedInstance
    @IBOutlet var labels: [UILabel]!
    @IBOutlet var labelViews: [UIView]!
    @IBOutlet var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buddy.fetchData()
        for index in 0...5{
            labels[index].text = buddy.itemNames[index]
            if buddy.itemBools[index] {
                labels[index].textColor = UIColor.blue
            } else {
                labels[index].textColor = UIColor.gray
            }
            let longPressRecognizer = (UILongPressGestureRecognizer(target: self, action: #selector(didPress(sender:))))
            labelViews[index].isUserInteractionEnabled = true
            labelViews[index].addGestureRecognizer(longPressRecognizer)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        buddy.safeReset()
        // Dispose of any resources that can be recreated.
    }

    //TODO: Unneeded?
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let viewController = segue.destination as? RootViewController
//        {
//            viewController.buddy = buddy
//        }
//    }
    
    
    //MARK: -
    //MARK: Functions
    //MARK: User Interaction Functions
    @IBAction func swipeHandler(_ gestureRecognizer : UISwipeGestureRecognizer) {
        guard gestureRecognizer.view != nil else {return}
        
        // Move the View Down with user's finger
        if gestureRecognizer.direction == .down
            && gestureRecognizer.state == .began {
            labels[0].textColor = UIColor.red
        }
        
        // Update the info, then release the view to go back up
        if gestureRecognizer.direction == .down
            && gestureRecognizer.state == .ended {
            buddy.fetchData()
            labelColorUpdate()
            labels[2].textColor = UIColor.red // Just to see if it works
            //UIView.animate(withDuration: 0.5, delay: 0.2, options: <#T##UIViewAnimationOptions#>, animations: <#T##() -> Void#>)
        }
    }
    
    //TODO: Make fancy (add extra window popup of info that moves with touch
    @objc func didPress(sender: UILongPressGestureRecognizer) {

        guard let index = labelViews.index(of: sender.view!) else {return}
        if sender.state == .began {
                if index < 3 || index == 5 {
                    if buddy.temperatureType == 0 {
                        labels[index].text = "\(buddy.dataEnglish[index]) º"
                    }
                    else if buddy.temperatureType == 1 {
                        labels[index].text = "\(buddy.dataMetric[index]) º"
                    }
                    else {
                        labels[index].text = "\(buddy.dataMetric[index]+275)"
                    }
                }
                else {
                    if buddy.measureSystem == 0 {
                        labels[index].text = "\(buddy.dataEnglish[index]) in"
                    }
                    else {
                        labels[index].text = "\(buddy.dataMetric[index]) cm"
                    }
                }
        }
        else if sender.state == .ended
            || sender.state == .cancelled {
            labels[index].text = buddy.itemNames[index]
        }
    }
    
    func labelColorUpdate(){
        for index in 0...5{
            if buddy.itemBools[index] {
                labels[index].textColor = UIColor.blue
            } else {
                labels[index].textColor = UIColor.gray
            }
        }
    }
    
    /*
    var initialCenter = CGPoint()  // The initial center point of the view
    @IBAction func panPiece(_ gestureRecognizer : UIPanGestureRecognizer) {
        guard gestureRecognizer.view != nil else {return}
        let piece = gestureRecognizer.view!
    // Get the changes in the X and Y directions relative the superview's coordinate space
        let translation = gestureRecognizer.translation(in: piece.superview)
        if gestureRecognizer.state == .began {
    // Save the view's original position.
            self.initialCenter = piece.center
        }
    // Update the position for the .began, .changed, and .ended states
        if gestureRecognizer.state != .cancelled {
    // Add the X and Y translation to the view's original position.
            let newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
            piece.center = newCenter   }
        else {
    // On cancellation, return the piece to its original location.
            piece.center = initialCenter
        }}
    
    func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer){
        
        buddy.getData()
        updateLabels()
    }*/
    
}

