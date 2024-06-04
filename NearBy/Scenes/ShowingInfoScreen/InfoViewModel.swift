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
    
    
    
    let statePublisher = BehaviorRelay<Bool>(value: true)
    let placesDataPublisher = PublishRelay<[PlaceResult]>()
    private var photoUrlCach = NSCache<NSString,NSURL>()//used to store the photo url to prevent redundunt requests
    
    let disposeBag : DisposeBag
    
    init(disposeBag:DisposeBag){
        self.disposeBag = disposeBag
        
        subscribeToCooridatePublisher()
        subscribeToErroPublisher()
        subscribeToDataPublisher()
    }
    
    
    
    
    //    MARK: - API Subscribetions
    
    private func sendRequest(lat:String,lon:String){
        statePublisher.accept(true)
        APIPlaceRequest.shared.placeSearchRequest(lat: lat, lon: lon)
    }
    
    //    subscribe to data publisher
    private func subscribeToDataPublisher(){
        APIPlaceRequest.shared.dataPublisher
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] event in
                if let results = event.element?.results{
                    self?.placesDataPublisher.accept(results)
                    
                    
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func subscribeToErroPublisher(){
        
        //    subscribe to error publisher from api services
        APIPlaceRequest.shared.errorPublisher
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] event in
                self?.statePublisher.accept(false)
                
            }
            .disposed(by: disposeBag)
    }
    
    
//    MARK: - location Manager subscribtions
    
    private func subscribeToCooridatePublisher(){
//        Get coordinates to send the request
        LocationManager.shared.coordinatesPublisher
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe {[weak self] coordinate in
                
                self?.sendRequest(lat: "\(coordinate.latitude)", lon: "\(coordinate.longitude)")
            }
            .disposed(by: disposeBag)
        
    }
    
    
    func glopalStateObservable()->Observable<Bool>{
//        Merge the state comes from the location manger with this view model's state
        let stateSource = Observable.of(LocationManager.shared.statePublisher.asObservable(),
                                        statePublisher.asObservable())
        
        return stateSource.merge()
    }
    

    
    
    
//    MARK: - fetch the photos URl
    
    func fetchPhotosUrl(place:PlaceResult)->Observable<URL?>{
        
        guard let id = place.fsqID else{//if id is not exists
            return Observable.just(nil)
        }
        
        if let cachUrl = photoUrlCach.object(forKey: id as NSString) as URL?{
            //if the url already exists in cach then return
            return Observable.just(cachUrl)
        }else{
            //if the url not exists in cach then buld the request
            let url = URL(string: "https://api.foursquare.com/v3/places/\(id)/photos")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = ["accept":"application/json" ,
                                           "Authorization":APIK.apiKey]
            
            return URLSession.shared.rx.data(request: request)
                .map {[weak self] data in
                    //get all the photos urls
                    let placePhotos = try? JSONDecoder().decode([PlacePhotoModel].self, from: data)
                    //then take only the first url then save it in cachs
                    if let placePhoto = placePhotos?.first , let urlString = placePhoto.smallPhotoUrlString, let url = URL(string: urlString){
                        self?.photoUrlCach.setObject(url as NSURL, forKey: id as NSString)
                        return url
                    }

                    return nil
                }
                .catchAndReturn(nil)// return nil if catch an error
        }
    }
    
}
