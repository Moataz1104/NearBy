//
//  LoadingViewModel.swift
//  NearBy
//
//  Created by Moataz Mohamed on 15/05/2024.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation


class LoadingViewModel{
    
    let disposeBag : DisposeBag
    
    let statePublisher = BehaviorRelay<Bool>(value: true) //state for something went wrong or not
    
    let placesDataPublisher = PublishRelay<[PlaceResult]>()
    
    
    init(disposeBag:DisposeBag){
        self.disposeBag = disposeBag
        LocationManager.shared.requestUserAuth()
        LocationManager.shared.checkAuthorizationStatus()
        
        subscribeToCooridatePublisher()
        subscribeToDataPublisher()
        subscribeToErroPublisher()


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
    
    func subscribeToCooridatePublisher(){ 
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
    
}



