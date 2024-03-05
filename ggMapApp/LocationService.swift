//
//  LocationService.swift
//  ggMapApp
//
//  Created by Edgar Grigoryan on 04.03.24.
//

import UIKit
import CoreLocation

protocol LocationServiceDelegate: AnyObject {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
}

class LocationService: NSObject {
    static let shared = LocationService()
    
    weak var delegate: LocationServiceDelegate?
    
    let locationManager = CLLocationManager()
    
    private override init() {
        super.init()

        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        authorizeIfNeeded()
        startMonitoringSignificantLocationChanges()
    }
    
    func startMonitoringSignificantLocationChanges() {
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopMonitoringSignificantLocationChanges() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
        
    func start() {
        locationManager.startUpdatingLocation()
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
    }
    
    func serviceEnabled(completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let locationService = CLLocationManager.locationServicesEnabled()
            DispatchQueue.main.async {
                completion(locationService)
            }
        }
    }
    
    func authorizationStatus() -> CLAuthorizationStatus {
        return locationManager.authorizationStatus
    }
    
    func authorized() -> Bool {
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            return true
        default:
            return false
        }
    }
    
    func authorizeIfNeeded() {
        guard !authorized() else { return }

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        default:
            break
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard locations.last != nil else { return }

        // handle locatoin update here
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        stop()
        stopMonitoringSignificantLocationChanges()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        delegate?.locationManager(manager, didChangeAuthorization: status)
    }
}
