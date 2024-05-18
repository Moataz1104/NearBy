//
//  LocationManager.swift
//  NearBy
//
//  Created by Moataz Mohamed on 18/05/2024.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa


class LocationManager : NSObject,CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    //state for something went wrong or not
    let statePublisher = BehaviorRelay<Bool>(value: true)
    let coordinatesPublisher = PublishRelay<CLLocationCoordinate2D>()
    private let locationManager = CLLocationManager()


    private override init(){
        super.init()
        locationManager.delegate = self
    }
    
    func checkAuthorizationStatus(){
        //Check the authorization status
        let status = locationManager.authorizationStatus
        
        switch status{
        case .authorizedAlways , .authorizedWhenInUse:
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
    
    func requestUserAuth(){
        locationManager.requestWhenInUseAuthorization()
    }
    
    
    
    
    
    
    //    MARK: - location manager delegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        //Check if the user changes the Authorization
        
        switch manager.authorizationStatus{
        case .authorizedAlways , .authorizedWhenInUse:
            statePublisher.accept(true)
            updateLocations()
            break
        default :
            statePublisher.accept(false)
            break
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let lastLocation = locations.last{
            print(lastLocation.coordinate)
            coordinatesPublisher.accept(lastLocation.coordinate)
            statePublisher.accept(true)
            locationManager.stopUpdatingLocation()
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        statePublisher.accept(false)
    }
    
}
