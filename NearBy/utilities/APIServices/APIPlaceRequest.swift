//
//  APIPlaceRequest.swift
//  NearBy
//
//  Created by Moataz Mohamed on 15/05/2024.
//

import Foundation
import RxSwift
import RxCocoa

class APIPlaceRequest {
    
    static let shared = APIPlaceRequest()
    private init(){}
    
    let dataPublisher = PublishRelay<PlaceModel>() //Emits the returned data
    let errorPublisher = PublishRelay<Error>() //Emits errors 
    
    
    
    //Build request to get places's data
    func placeSearchRequest(lat:String,lon:String){
        guard let url = URL(string: APIK.baseUrlString) else{
            errorPublisher.accept(NSError(domain: "URL Error", code: 0))
            return
        }
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.path.append("/search")

        let coordinateItems = URLQueryItem(name: "ll", value: "\(lat),\(lon)")
        let radiusItems = URLQueryItem(name: "radius", value: "1000")
        
        urlComponents?.queryItems = [coordinateItems,radiusItems]
        
        
        
        guard let finalUrl = urlComponents?.url else{
            
            errorPublisher.accept(NSError(domain: "URL Error", code: 0))
            return}
        
        
        var request = URLRequest(url: finalUrl)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = ["accept":"application/json" ,
                                       "Authorization":APIK.apiKey
        ]
        
        APIBaseSession.baseSession(request: request) {[weak self] result in
            switch result{
            case .success(let data) :
                if let data {
                    
                    do{
                        let decodedData = try JSONDecoder().decode(PlaceModel.self, from: data)
                        self?.dataPublisher.accept(decodedData)
                    }catch{
                        
                    }
                }
            case .failure(let error):
                
                self?.errorPublisher.accept(error)
            }
        }
    }
    
}
