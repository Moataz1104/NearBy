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

    var selectedMode = UserDefaults.standard.string(forKey: "selectedMode") ?? "Realtime"
    

    private override init(){
        super.init()
        locationManager.delegate = self
        checkAuthorizationStatus()

    }
    
    func checkAuthorizationStatus(){
        //Check the authorization status
        let status = locationManager.authorizationStatus
        print("Check status")
        switch status{
        case .authorizedAlways , .authorizedWhenInUse:
            updateLocations()
            statePublisher.accept(true)
            break
        case .denied:
            statePublisher.accept(false)
        default:
            statePublisher.accept(true )
        }
    }
    
    func updateLocations(){
        statePublisher.accept(true)
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
        case .authorizedAlways , .authorizedWhenInUse,.notDetermined :
            statePublisher.accept(true)
            updateLocations()
            break
        case .denied , .restricted :
            statePublisher.accept(false)
            break
        default :
            statePublisher.accept(true)
            break
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let lastLocation = locations.last{
            print("send Coordinates: \(lastLocation.coordinate)")
            statePublisher.accept(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){[weak self] in
                self?.coordinatesPublisher.accept(lastLocation.coordinate)
            }
            
        }
        if selectedMode == "Realtime"{
            updateLocations()
        }else{
            locationManager.stopUpdatingLocation()
        }

        print(selectedMode)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        print("3")
        statePublisher.accept(false)
    }
    
}
