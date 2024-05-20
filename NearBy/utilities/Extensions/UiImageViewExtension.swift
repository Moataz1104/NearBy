//
//  UiImageViewExtension.swift
//  NearBy
//
//  Created by Moataz Mohamed on 18/05/2024.
//

import Foundation
import UIKit

extension UIImageView{
    
//    Add extension to uiimageview to load the images form url and update it in the image view
    func loadImage(url:URL)->URLSessionDownloadTask{
        
        let downloadTask = URLSession.shared.downloadTask(with:url){[weak self] url,_,error in
            if error == nil ,
               let url = url ,
               let data = try? Data(contentsOf: url) ,
               let image = UIImage(data: data){
                guard let self = self else{return}
                DispatchQueue.main.async {
                    self.image = image
                    
                }
            }else{
                self?.image = UIImage(systemName: "photo.artframe")
            }
            
            
        }
        downloadTask.resume()
        return downloadTask
    }
}

