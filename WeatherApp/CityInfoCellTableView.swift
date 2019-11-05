//
//  CityInfoCellTableView.swift
//  WeatherApp
//
//  Created by Albert Duz on 05/11/2019.
//  Copyright © 2019 Albert Duz. All rights reserved.
//

import UIKit

class CityInfoCellTableView: UITableViewCell {

    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var cityView: UILabel!
    @IBOutlet weak var tempView: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
