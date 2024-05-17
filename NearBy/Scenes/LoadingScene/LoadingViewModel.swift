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
    var locationManager = CLLocationManager()
    
    
    init(disposeBag:DisposeBag){
        self.disposeBag = disposeBag
        
        subscribeToDataPublisher()
        subscribeToErroPublisher()
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
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
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
            .subscribe {[weak self] event in
                self?.statePublisher.accept(false)
                print(event.element?.localizedDescription ?? "No Error")
            }
            .disposed(by: disposeBag)
    }
}



//MARK: - Core location Authorizations
extension LoadingViewModel{
    
    func checkAuthorizationStatus(){
        //Check the authorization status
        let status = locationManager.authorizationStatus
        
        switch status{
        case .authorizedAlways , .authorizedWhenInUse  :
            updateLocations()
            statePublisher.accept(true)
            break
        default:
            statePublisher.accept(false)
        }
    }
    
    func updateLocations(){
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
    }
    
    
}

