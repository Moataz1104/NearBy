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
    func placeSearchRequest(){
        guard let url = URL(string: APIK.baseUrlString) else{
            errorPublisher.accept(NSError(domain: "URL Error", code: 0))
            return
        }
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.path.append("/search")
        guard let finalUrl = urlComponents?.url else{
            print("Invalid URL")
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
                    print(data)
                    do{
                        let decodedData = try JSONDecoder().decode(PlaceModel.self, from: data)
                        self?.dataPublisher.accept(decodedData)
                    }catch{
                        print(error.localizedDescription)
                    }
                }
            case .failure(let error):
                print(error)
                self?.errorPublisher.accept(error)
            }
        }
    }
    
}
