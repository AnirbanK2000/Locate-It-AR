//
//  ViewController.swift
//  AR Locator
//
//  Created by Anirban Kumar on 6/22/19.
//  Copyright © 2019 Anirban Kumar. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData
import MessageUI
import GoogleMobileAds
class MainViewController: UIViewController , UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var dropPinButton: UIButton!
    @IBOutlet weak var viewAllButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    
    let locationManger = CLLocationManager()
    
    let regionMeters : Double = 2000
    
    var locationInfo : [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAds()
        setupSwipes()
        setupButtons()
        checkLocationServices()
    }
    
    func setupAds() {
        //test ca-app-pub-3940256099942544/2934735716
        //normal ca-app-pub-4924608405742253/5582469401
        bannerView.adUnitID = "ca-app-pub-4924608405742253/5582469401"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }
    
    func setupButtons() {
        dropPinButton.layer.cornerRadius = 20
        viewAllButton.layer.cornerRadius = 20
        dropPinButton.layer.masksToBounds = true
        viewAllButton.layer.masksToBounds = true
    }
    
    func setupSwipes(){
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didDragMap(_:)))
        panGesture.delegate = self
        mapView.addGestureRecognizer(panGesture)
    }
    
    func setupLocationManager() {
        locationManger.delegate = self
        //mapView.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerOnUserLocation() {
        if let location = locationManger.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
            mapView.setRegion(region, animated: true)
            if let image = UIImage(named: "location-filled")  {
                self.locationButton.setImage(image, for: .normal)
                self.locationButton.imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
            }
        }
    }
    
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse :
            mapView.showsUserLocation = true
            centerOnUserLocation()
            locationManger.startUpdatingLocation()
            break
        case .denied :
            //SHOW ALERT W/ INSTRUCTION
            break
        case .notDetermined :
            locationManger.requestWhenInUseAuthorization()
        case . restricted :
            break
        case .authorizedAlways :
            break
        @unknown default:
            break
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func didDragMap(_ sender: UIGestureRecognizer) {
        if let image = UIImage(named: "location-unfilled")  {
            self.locationButton.setImage(image, for: .normal)
            self.locationButton.imageEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        }
    }
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        centerOnUserLocation()
    }
    
    @IBAction func dropPinButtonTapped(_ sender: Any) {
        //ask for what pin they're dropping
        let alert = UIAlertController(title: "Dropping Pin",
                                      message: "What are you pinning?",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            guard let textField = alert.textFields?.first, let nameToSave = textField.text else {
                return
            }
            let coordinates = self.locationManger.location?.coordinate
            self.save(title: nameToSave, longitude: coordinates?.longitude as! Double, latitude: coordinates?.latitude as! Double)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @IBAction func suggestionTapped(_ sender: Any) {
        if !MFMailComposeViewController.canSendMail() {
            let alert = UIAlertController(title: "Error", message: "Please send your suggestions to anisingh2000@gmail.com", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
            print("cant")
            return
        } else {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self

            composeVC.setToRecipients(["anisingh2000@gmail.com"])
            composeVC.setSubject("AR Locator Suggestion")
            composeVC.setMessageBody("Hey, ", isHTML: false)

            self.present(composeVC, animated: true, completion: nil)
        }
    }
    
    func save(title: String, longitude: Double, latitude: Double) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let entity =
            NSEntityDescription.entity(forEntityName: "Location",
                                       in: managedContext)!
        
        let location = NSManagedObject(entity: entity,
                                       insertInto: managedContext)
        
        location.setValue(title, forKeyPath: "name")
        location.setValue(longitude, forKey: "longitude")
        location.setValue(latitude, forKey: "latitude")
        
        do {
            try managedContext.save()
            locationInfo.append(location)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

extension MainViewController : GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
}

extension MainViewController : MFMailComposeViewControllerDelegate {
    
    func mailComposeController(controller: MFMailComposeViewController,
                               didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        // Check the result or perform other tasks.
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
}

extension MainViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionMeters, longitudinalMeters: regionMeters)
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

