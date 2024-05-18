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
    
    
    var downloadTask:URLSessionDownloadTask?

    override func awakeFromNib() {
        super.awakeFromNib()    
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadTask?.cancel()
        downloadTask = nil
    }
    
    
    
    func configImage(with url : URL){
        //Update the image
        DispatchQueue.main.async {[weak self] in
            self?.downloadTask = self?.placeImage.loadImage(url: url)
        }
    }

    
    
}
