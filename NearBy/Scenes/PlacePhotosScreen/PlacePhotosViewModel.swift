//
//  PlacePhotosViewModel.swift
//  NearBy
//
//  Created by Moataz Mohamed on 04/06/2024.
//

import Foundation
import RxSwift
import RxCocoa


class PlacePhotosViewModel{
    
    
    var fetchedPhotosData : [PlacePhotoModel]?
    var reloadTable : (()->Void)?
    
    //    MARK: - fetch the photos URl
    
    func fetchPhotosUrl(id:String){
        
        let url = URL(string: "https://api.foursquare.com/v3/places/\(id)/photos")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = ["accept":"application/json" ,
                                       "Authorization":APIK.apiKey]
        
        
        let dataTask = URLSession.shared.dataTask(with: request){[weak self] data,response,error in
            guard error == nil else{return}
            
            if let data = data{
                do{
                    let decodedData = try JSONDecoder().decode([PlacePhotoModel].self, from: data)
                    self?.fetchedPhotosData = decodedData
                    print("33333")
                    self?.reloadTable!()
                }catch{
                    print(error)
                }
            }
        }
        dataTask.resume()
        
        //        return URLSession.shared.rx.data(request: request)
        //            .map { data in
        //                //get all the photos urls
        //                let placePhotos = try? JSONDecoder().decode([PlacePhotoModel].self, from: data)
        //                return placePhotos
        //
        //            }
        //            .catchAndReturn(nil)// return nil if catch an error
        //    }
        
        print("44444")
        
    }
}
