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
    
    
    
    func configImage(with place : PlaceResult,viewModel:InfoViewModel){
        viewModel.fetchPhotosUrl(place: place) {[weak self] url, error in
            guard let url = url , error == nil else{return}
            
            DispatchQueue.main.async {
                self?.downloadTask = self?.placeImage.loadImage(url: url)
            }
        }
        
        placeName.text = place.name ?? "No Name"
        placeAddress.text = place.location?.formattedAddress ?? "No Address"
    }

    
    
}
