//
//  ARViewController.swift
//  AR Locator
//
//  Created by Anirban Kumar on 6/22/19.
//  Copyright © 2019 Anirban Kumar. All rights reserved.
//

import UIKit
import CoreLocation
import ARCL
import MapKit

class ARViewController: UIViewController {

    var lat: Double = 0
    var long: Double = 0
    
    var name : String = ""

    var sceneLocationView = SceneLocationView()
    
    let locationManger = CLLocationManager()

    var routeCoordinates = [CLLocationCoordinate2D]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocationManager()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "AR Directions", style: .plain, target: self, action: #selector(directions))
        
        sceneLocationView.run()
        sceneLocationView.frame = view.bounds
        
        let textNode = buildViewNode(latitude: lat, longitude: long, altitude: 100, text: name)
        
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: textNode)
        
        view.addSubview(sceneLocationView)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = view.bounds
    }
    
    @objc func directions(){
//        guard let userCoordinate = locationManger.location?.coordinate else { return }
//        let placemark = CLLocationCoordinate2D(latitude: lat, longitude: long)
//        calculateDirections(from: userCoordinate, to: placemark)
//
//        let directionsViewControl = DirectionsViewController()
//        directionsViewControl.routeCoordinates = self.routeCoordinates
//        self.navigationController?.pushViewController(directionsViewControl, animated: true)
        let alert = UIAlertController(title: "Feature Not Available Yet", message: "AR Directions will be coming soon!", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Can't Wait", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneLocationView.pause()
    }
    func setupLocationManager() {
        locationManger.delegate = self
        //mapView.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func buildViewNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                       altitude: CLLocationDistance, text: String) -> LocationAnnotationNode {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = CLLocation(coordinate: coordinate, altitude: altitude)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        
        let loc = locationManger.location?.coordinate
        let current = CLLocation(latitude: loc!.latitude, longitude: loc!.longitude)
        
        
        var distance = location.distance(from: current) as Double
        distance = distance * 0.000621371
        
        let roundedDistance = round(100.0 * distance) / 100.0
        
        let content: String = text + "\n \(roundedDistance) mi."
        
        label.text = content
        label.numberOfLines = 2
        label.layer.cornerRadius = 25
        label.layer.masksToBounds = true
        label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        label.backgroundColor = #colorLiteral(red: 0.8946771026, green: 0.8893589377, blue: 0.8987652659, alpha: 1)
        label.textAlignment = .center
        
        return LocationAnnotationNode(location: location, view: label)
    }
    
    func calculateDirections(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        let sourcePlacemark = MKPlacemark(coordinate: source)
        let destPlacemark = MKPlacemark(coordinate: destination)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destMapItem = MKMapItem(placemark: destPlacemark)
        let request = MKDirections.Request()
        request.source = sourceMapItem
        request.destination = destMapItem
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            
            if let error = error {
                print("There was an error " + error.localizedDescription)
                return
            }
            
            if let routeResponse = response?.routes {
                let route: MKRoute =
                    routeResponse.sorted(by: {$0.expectedTravelTime <
                        $1.expectedTravelTime})[0]
                
                // TODO: Implement travel time functionality
                print("Expected travel time \(route.expectedTravelTime)")
                
                // First of all overlay the route on the MapView
                for step in route.steps {
                    let stepCoordinate = step.polyline.coordinate
                    self.routeCoordinates.append(stepCoordinate)
                    
                    let stepLocation = CLLocation(latitude: stepCoordinate.latitude, longitude: stepCoordinate.longitude)
                }
                self.plotPolyline(route: route)
            }
        }
    }
    
    func plotPolyline(route: MKRoute) {
       // mapView.add(route.polyline)
        // Set map view visible area
        //mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
    }
    
}
extension ARViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
    }
    
}
