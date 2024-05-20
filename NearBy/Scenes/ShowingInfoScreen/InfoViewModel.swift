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
    let placesDataPublisher = PublishRelay<[PlaceResult]>()

    
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
                print(event.element?.localizedDescription ?? "No Error")
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
                print("Coordinates from subscribtion")
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
    

    
    
    
//    MARK: - fetch the photos
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
