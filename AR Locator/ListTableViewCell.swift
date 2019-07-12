//
//  ListTableViewCell.swift
//  AR Location
//
//  Created by Anirban Kumar on 6/17/19.
//  Copyright © 2019 Anirban Kumar. All rights reserved.
//

import UIKit
import MapKit

class ListTableViewCell: UITableViewCell {

    static let reuseIdentifier = "LocationCell"
   
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var longCoord: UILabel!
    @IBOutlet var latCoord: UILabel!
    @IBOutlet var something: UIButton!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var directionsButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func directionsButtonTapped(_ sender: Any) {
        print("testing button pressed")
    }

}
