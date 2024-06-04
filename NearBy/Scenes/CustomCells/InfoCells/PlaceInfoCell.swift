//
//  PlaceInfoCell.swift
//  NearBy
//
//  Created by Moataz Mohamed on 17/05/2024.
//

import UIKit
import RxSwift
import RxCocoa

class PlaceInfoCell: UITableViewCell {
    static let identifier = "PlaceInfoCell"
    
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var placeAddress: UILabel!
    
    
    var viewModel : InfoViewModel?
    var imageLoadDisposable : Disposable?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        //dispose the image loading and set image to nil before reuse the cells
        imageLoadDisposable?.dispose()
        placeImage.image = nil
    }
    
    
    
    func configImage(with place : PlaceResult , disposeBag:DisposeBag){
        viewModel?.fetchPhotosUrl(place: place)
            .compactMap{$0}//remove the nil values and unwrap the other values
            .subscribe(onNext: {[weak self] url in
                DispatchQueue.main.async{
                    //make animation
                    UIView.transition(with: self?.placeImage ?? UIImageView(), duration: 0.1,options: .transitionCrossDissolve) {
                        self?.imageLoadDisposable = self?.placeImage.loadImage(url: url)
                            
                    }
                }
                
            })
            .disposed(by:disposeBag)
        
        placeName.text = place.name ?? "No Name"
        placeAddress.text = place.location?.formattedAddress ?? "No Address"
    }
}
