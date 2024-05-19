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
    var dataTask:URLSessionDataTask?
    
    let statePublisher = BehaviorRelay<Bool>(value: true)
        
    
    
    
    func fetchPhotosUrl(place : PlaceResult , completion:@escaping(URL?,Error?) -> Void){
        guard let id = place.fsqID else{
            print("No id")
            DispatchQueue.main.async{[weak self] in
                completion(nil,NSError(domain: "URL Error", code: 0))
                self?.statePublisher.accept(false)
            }
            return
        }
        
//        Check if the url already exists or not
        if let cachedUrl = photoURlCach[id]{
            
            DispatchQueue.global().async {
                completion(cachedUrl,nil)
                DispatchQueue.main.async {[weak self] in
                    self?.statePublisher.accept(true)
                }
            }
            
            return
        }else{
            
            let url = URL(string: "https://api.foursquare.com/v3/places/\(id)/photos")!
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = ["accept" : "application/json",
                                           "Authorization":APIK.apiKey
            ]
            dataTask = URLSession.shared.dataTask(with: request) {[weak self] data, response, error in
                guard let data = data , error == nil else {
                    DispatchQueue.main.async {
                        completion(nil , error)
                        self?.statePublisher.accept(false)
                    }
                    return}
                do{
                    let placePhotos = try JSONDecoder().decode([PlacePhotoModel].self, from: data)
                    //Get the first photo
                    if let placePhoto = placePhotos.first, let url = URL(string:placePhoto.photoUrlString!){
                        
                        self?.photoURlCach[id] = url
                        DispatchQueue.global().async {
                            completion(url,nil)
                            DispatchQueue.main.async {
                                self?.statePublisher.accept(true)
                            }
                        }
                    }
                }catch{
                    print(error.localizedDescription)
                    DispatchQueue.global().async {[weak self] in
                        completion(nil,error)
                        DispatchQueue.main.async {
                            self?.statePublisher.accept(false)
                        }
                    }
                }
            }
            dataTask?.resume()
            
        }
    }
}
