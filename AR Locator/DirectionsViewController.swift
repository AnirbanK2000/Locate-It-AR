//
//  DirectionsViewController.swift
//  AR Locator
//
//  Created by Anirban Kumar on 6/25/19.
//  Copyright © 2019 Anirban Kumar. All rights reserved.
//

import UIKit
import SceneKit
import MapKit
import CoreLocation
import CocoaLumberjack
import ARCL

let Altitude: CLLocationDistance = 20

class DirectionsViewController: UIViewController  {
   
    var sceneLocationView = SceneLocationView()

    var routeCoordinates = [CLLocationCoordinate2D]()
    
    let metersPerNode: CLLocationDistance = 25

    override func viewDidLoad() {
        super.viewDidLoad()

//        sceneLocationView.locationViewDelegate = self as! SceneLocationViewDelegate
        //sceneLocationView.delegate = self
        sceneLocationView.locationViewDelegate = self
        
        view.addSubview(sceneLocationView)
        self.plotARRoute()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneLocationView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneLocationView.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height)
    }
    
    func plotARRoute() {
        // First remove all AR nodes previously plotted
        sceneLocationView.removeAllNodes()
        
        // Add an AR annotation for every coordinate in routeCoordinates
        for coordinate in routeCoordinates {
            print("HELLO IM HERE")

            // TODO: Change altitude so that it is not hard coded
            let nodeLocation = CLLocation(coordinate: coordinate, altitude: Altitude)
            let locationAnnotation = LocationAnnotationNode(location: nodeLocation, image: UIImage(named: "pin")!)
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: locationAnnotation)
        }
        
        // Use Turf to find the total distance of the polyline
        let distance = Turf.distance(along: routeCoordinates)
        
        // Walk the route line and add a small AR node and map view annotation every metersPerNode
        for i in stride(from: 0, to: distance, by: metersPerNode) {
            // Use Turf to find the coordinate of each incremented distance along the polyline
            if let nextCoordinate = Turf.coordinate(at: i, fromStartOf: routeCoordinates) {
                let interpolatedStepLocation = CLLocation(coordinate: nextCoordinate, altitude: Altitude)
                
                // Add an AR node
                let locationAnnotation = LocationAnnotationNode(location: interpolatedStepLocation, image: UIImage(named: "middleNode")!)
                sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: locationAnnotation)
                print("added")
            }
        }
    }
}
extension DirectionsViewController: SceneLocationViewDelegate {
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) { }
    
    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) { }
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) { }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) { }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) { }
}

extension DispatchQueue {
    func asyncAfter(timeInterval: TimeInterval, execute: @escaping () -> Void) {
        self.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: execute)
    }
}
