//
//  PhotoCell.swift
//  NearBy
//
//  Created by Moataz Mohamed on 04/06/2024.
//

import UIKit
import RxSwift
import RxCocoa

class PhotoCell: UITableViewCell {
    static let identifier = "PhotoCell"

    @IBOutlet weak var placeLargeImage: UIImageView!
    
    
    var imageLoadDisposable : Disposable?

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        //dispose the image loading and set image to nil before reuse the cells
        imageLoadDisposable?.dispose()
        placeLargeImage.image = nil
    }

    
    
    func configImage(urlString : String){
        let url = URL(string: urlString)!
        
        imageLoadDisposable = placeLargeImage.loadImage(url: url)
    }
    
}
