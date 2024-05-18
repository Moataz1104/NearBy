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

        subscribeToDataPublisher()
        subscribeToErroPublisher()
        subscribeToCooridatePublisher()


    }
    
    
    
    //    MARK: - API Subscribetions
    
    func sendRequest(lat:String,lon:String){
        APIPlaceRequest.shared.placeSearchRequest(lat: lat, lon: lon)
        statePublisher.accept(true)
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
    
    //    subscribe to error publisher
    private func subscribeToErroPublisher(){
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
        LocationManager.shared.coordinatesPublisher
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe {[weak self] coordinate in
                self?.sendRequest(lat: "\(coordinate.latitude)", lon: "\(coordinate.longitude)")
            }
            .disposed(by: disposeBag)
        
    }
    
}



