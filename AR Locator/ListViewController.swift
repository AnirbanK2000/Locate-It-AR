//
//  ListViewController.swift
//  AR Location
//
//  Created by Anirban Kumar on 6/17/19.
//  Copyright © 2019 Anirban Kumar. All rights reserved.
//

import UIKit
import CoreData
import ARCL
import CoreLocation
import MapKit

class ListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var names : [String] = []
    var longitude : [Double] = []
    var latitude : [Double] = []
    
    var sceneLocationView = SceneLocationView()
    
    let locationManger = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupLocationManager()

        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        request.returnsObjectsAsFaults = false
        do {
            let result = try managedContext.fetch(request)
            for data in result as! [NSManagedObject] {
                names.append(data.value(forKey: "name") as! String)
                longitude.append(data.value(forKey: "longitude") as! Double)
                latitude.append(data.value(forKey: "latitude") as! Double)
            }
        } catch {
            print("Failed")
        }
        if names.count > 0 {
             navigationItem.rightBarButtonItem = UIBarButtonItem(title: "View All Pins in AR", style: .plain, target: self, action: #selector(viewAll))
        }
    }
    func setupLocationManager() {
        locationManger.delegate = self
        //mapView.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
    }
    @objc func viewAll(){
        sceneLocationView.run()
        sceneLocationView.frame = view.bounds
        buildAllData().forEach() {
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: $0)
        }
        view.addSubview(sceneLocationView)
    }
    
    func buildAllData() -> [LocationAnnotationNode] {
        var nodes: [LocationAnnotationNode] = []
        
        for i in 0..<(longitude.count) {
            let node = buildViewNode(latitude: latitude[i], longitude: longitude[i], altitude: 100, text: names[i])
            nodes.append(node)
        }
        
        return nodes
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
    
}
extension ListViewController: UITableViewDataSource , UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.reuseIdentifier, for: indexPath) as? ListTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        
        let name = names[indexPath.row]
        let long = longitude[indexPath.row]
        let lat = latitude[indexPath.row]
        
        cell.titleLabel.text = name
        cell.latCoord.text = "\(long)"
        cell.longCoord.text = "\(lat)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let arViewControl = ARViewController()
        arViewControl.lat = latitude[indexPath.row]
        arViewControl.long = longitude[indexPath.row]
        arViewControl.name = names[indexPath.row]
        
        
        self.navigationController?.pushViewController(arViewControl, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            let managedContext =
                appDelegate.persistentContainer.viewContext
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
            request.returnsObjectsAsFaults = false
            do {
                let result = try managedContext.fetch(request)
                for data in result as! [NSManagedObject] {
                    if names[indexPath.row] == data.value(forKey: "name") as! String ,
                       longitude[indexPath.row] == data.value(forKey: "longitude") as! Double ,
                       latitude[indexPath.row] == data.value(forKey: "latitude") as! Double {
                            managedContext.delete(data)
                        names.remove(at: indexPath.row)
                        longitude.remove(at: indexPath.row)
                        latitude.remove(at: indexPath.row)
                        break
                    }
                }
            } catch {
                print("Failed")
            }
            
            tableView.reloadData()
        }
    }
    
    
}
extension ListViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
    }
    
}
