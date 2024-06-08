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
    private var realTimeArray = [CLLocation]()
    private var lastRetrievedPlacesLocation :CLLocation?
    private var coordinatesWillEmited : CLLocationCoordinate2D?

    private var isFirstTimeIntialize : Bool!//handle the first time for the subscribtion on coordinatesPublisher not be too early
    
    
    var selectedMode = UserDefaults.standard.string(forKey: "selectedMode") ?? "Realtime"
    

    private override init(){
        super.init()
        isFirstTimeIntialize = true
        locationManager.delegate = self
        requestUserAuth()
        checkAuthorizationStatus()
        
        

    }
    
    func checkAuthorizationStatus(){
        //Check the authorization status
        let status = locationManager.authorizationStatus
        
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
    
    private func handleRealTimeUpdates(lastLocation:CLLocation){
        if lastRetrievedPlacesLocation == nil {
            //Assign value to the last retrieved places location if it is nil
            lastRetrievedPlacesLocation = lastLocation
            coordinatesWillEmited = lastRetrievedPlacesLocation?.coordinate
        }
        
        if realTimeArray.isEmpty{
            //Append the last retrieved places location in the first index
            realTimeArray.append(lastRetrievedPlacesLocation!)
        }
        if realTimeArray.count == 1{
            //Append any other location in the second index
            realTimeArray.append(lastLocation)
        }
        
        if realTimeArray.count == 2{
            //if the array is completed with two elements then check if the diff is 500m
            realTimeArray[1] = lastLocation
            if realTimeArray[0].distance(from: realTimeArray[1]) > 100 {
                //if the diff is 500m then replace the first index with the second index which is the updated location then emit this coordinates
                realTimeArray[0] = realTimeArray[1]
                coordinatesWillEmited = realTimeArray[0].coordinate
            }else{
                //Assign this variable with nil to guarantee that no coordinates will be emitted
                coordinatesWillEmited = nil
            }
            
        }

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
        
        
        guard let lastLocation = locations.last else{ statePublisher.accept(false)
            return}
        
        handleRealTimeUpdates(lastLocation: lastLocation)
        
        
        if selectedMode == "Realtime"{
            if isFirstTimeIntialize{
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5){[weak self] in
                    self?.coordinatesPublisher.accept(lastLocation.coordinate)
                }
            }
            if let coordinatesWillEmited = coordinatesWillEmited{

                coordinatesPublisher.accept(coordinatesWillEmited)
            }
        }else{
            if isFirstTimeIntialize{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){[weak self] in
                    self?.coordinatesPublisher.accept(lastLocation.coordinate)
                    self?.locationManager.stopUpdatingLocation()
                }
            }else{
                coordinatesPublisher.accept(lastLocation.coordinate)
                locationManager.stopUpdatingLocation()
            }
        }
        
        isFirstTimeIntialize = false
        statePublisher.accept(true)

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError{
            if clError.code == .locationUnknown{
                
            }else{
                statePublisher.accept(false)
            }
        }
    }
    
}
