//
//  PlaceInfoCell.swift
//  NearBy
//
//  Created by Moataz Mohamed on 17/05/2024.
//

import UIKit

class PlaceInfoCell: UITableViewCell {
    static let identifier = "PlaceInfoCell"
    
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var placeAddress: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()        
    }

    
}
