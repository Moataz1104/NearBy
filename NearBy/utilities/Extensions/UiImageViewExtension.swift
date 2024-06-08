//
//  UiImageViewExtension.swift
//  NearBy
//
//  Created by Moataz Mohamed on 18/05/2024.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
extension UIImageView{
    
//    Add extension to uiimageview to load the images form url and update it in the image view
    func loadImage(url:URL)->Disposable{
        
        DispatchQueue.main.async{[weak self] in
            self?.image = UIImage(systemName: "photo")
        }
        
        return URLSession.shared.rx.data(request: URLRequest(url: url))
            .map {data in
                return UIImage(data: data) // get the uiimage data
            }
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] image in
                if let image{
                    self?.image = image //set the image to be the returned data
                }else{
                    self?.image = UIImage(systemName: "photo.artframe")
                }
            }onError: {[weak self] _ in
                self?.image = UIImage(systemName: "photo.artframe")
            }
    }
}

