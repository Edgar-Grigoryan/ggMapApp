//
//  ViewController.swift
//  ggMapApp
//
//  Created by Edgar Grigoryan on 04.03.24.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    @IBOutlet private weak var userLocationButton: UIButton!
    @IBOutlet private weak var mapView: MKMapView!
    private var isFirstUserLocationUpdate = true
    
    private let locationService = LocationService.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        mapView.delegate = self
        locationService.delegate = self

        addUserTrackingOnMap()
    }
    
    private func setupUI() {
        userLocationButton.backgroundColor = .white
        userLocationButton.layer.cornerRadius = 25
        userLocationButton.layer.shadowColor = UIColor.black.cgColor
        userLocationButton.layer.shadowOpacity = 0.5
        userLocationButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        userLocationButton.addTarget(self, action: #selector(focusMapOnUserLocation), for: .touchUpInside)
        view.addSubview(userLocationButton)
    }
    
    @objc func focusMapOnUserLocation() {
        if (!locationService.authorized()) {
            switch locationService.authorizationStatus() {
            case .denied:
                locationService.serviceEnabled { serviceEnabled in
                    if (!serviceEnabled) {
                        self.showLocationServiceDisabledAlert()
                    } else {
                        self.showLocationAccessDeniedAlert()
                    }
                }
            default:
                break
            }
        } else {
            focusOnUserLocation()
        }
    }
    
    private func focusOnUserLocation() {
        mapView.focusOnCoordinate(coordinate: mapView.userLocation.location?.coordinate)
    }
    
    private func addUserTrackingOnMap() {
        let authorized = locationService.authorized()
        mapView.showsUserLocation = authorized
        if (authorized) {
            locationService.start()
        } else {
            locationService.stop()
        }
    }
}

// MARK: MKMapViewDelegate implementation

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard isFirstUserLocationUpdate, let coordinate = userLocation.location?.coordinate else { return }
        
        mapView.focusOnCoordinate(coordinate: coordinate)
        isFirstUserLocationUpdate = false
    }
}

// MARK: LocationServiceDelegate implementation

extension ViewController: LocationServiceDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        addUserTrackingOnMap()
        focusOnUserLocation()
        
        locationService.serviceEnabled { serviceEnabled in
            if (!serviceEnabled) {
                self.showLocationServiceDisabledAlert()
            } else {
                self.locationService.authorizeIfNeeded()
            }
        }
    }
}

// MARK: Alerts

private extension ViewController {
    func showLocationServiceDisabledAlert() {
        let title = "Location services disabled"
        let message = "Please enable location services in Settings -> Privacy & Security -> Location Services"

        showAlert(title: title, message: message)
    }
    
    func showLocationAccessDeniedAlert() {
        let title = "Location Access Denied"
        let message = "Please enable location access in Settings to use this feature"
        
        showAlert(title: title, message: message)
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (_) in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }))
        present(alertController, animated: true, completion: nil)
    }
}

