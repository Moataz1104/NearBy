//
//  InfoViewModel.swift
//  NearBy
//
//  Created by Moataz Mohamed on 18/05/2024.
//

import Foundation

import RxSwift
import RxCocoa


class InfoViewModel{
    
    
    private var photoURlCach:[String:URL] = [:]
    
    
    
    func fetchPhotosUrl(place : PlaceResult , completion:@escaping(URL?,Error?) -> Void){
        guard let id = place.fsqID else{
            print("No id")
            completion(nil,NSError(domain: "URL Error", code: 0))
            return
        }
        
//        Check if the url already exists or not
        if let cachedUrl = photoURlCach[id]{
            completion(cachedUrl, nil)
        }else{
            
            let url = URL(string: "https://api.foursquare.com/v3/places/\(id)/photos")!
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = ["accept" : "application/json",
                                           "Authorization":APIK.apiKey
            ]
            let dataTask = URLSession.shared.dataTask(with: request) {[weak self] data, response, error in
                guard let data = data , error == nil else {completion(nil , error); return}
                do{
                    let placePhotos = try JSONDecoder().decode([PlacePhotoModel].self, from: data)
                    if let placePhoto = placePhotos.first, let url = URL(string:placePhoto.photoUrlString!){
                        self?.photoURlCach[id] = url
                        completion(url,nil)
                    }
                }catch{
                    print(error.localizedDescription)
                    completion(nil,error)
                }
            }
            dataTask.resume()
            
        }
    }
}
