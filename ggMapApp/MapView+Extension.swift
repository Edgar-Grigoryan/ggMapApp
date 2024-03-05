//
//  MapView+Extension.swift
//  ggMapApp
//
//  Created by Edgar Grigoryan on 04.03.24.
//

import MapKit

extension MKMapView {
    func focusOnCoordinate(coordinate: CLLocationCoordinate2D?) {
        guard let coordinate = coordinate else { return }
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1500, longitudinalMeters: 1500)
        setRegion(region, animated: true)
    }
}

