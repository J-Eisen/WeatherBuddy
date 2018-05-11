//
//  CalendarTableViewCell.swift
//  WeatherBuddy
//
//  Created by Jonah Eisenstock on 2/26/18.
//  Copyright © 2018 JonahEisenstock. All rights reserved.
//

import UIKit

class CalendarTableViewCell: UITableViewCell {

    @IBOutlet weak var calendarOn: UIButton!
    @IBOutlet weak var calendarColor: UIImageView!
    @IBOutlet weak var calendarName: UILabel!
    
    var color: UIColor = UIColor.clear
    
    override func awakeFromNib() {
        super.awakeFromNib()
        drawCircle(calendarOn.frame, UIColor.green)
        drawCircle(calendarColor.frame, color)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func drawCircle(_ rect: CGRect,_ color: UIColor) {
        let path = UIBezierPath(ovalIn: rect)
        color.setFill()
        path.fill()
    }
    
    @IBAction func button(_ sender: UIButton) {
    }

}
