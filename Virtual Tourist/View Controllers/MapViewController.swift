//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Анна Соловьева on 17/10/2020.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

    // MARK: Initializing of variables
    @IBOutlet weak var mapView: MKMapView!
    var pins: [Pin] = []
    
    
    // MARK: UIView
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        mapView.addGestureRecognizer(longTapGesture)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        setUpPinFetchRequest(appDelegate)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        setUpPinFetchRequest(appDelegate)
        
    }

}


extension MapViewController: MKMapViewDelegate {
    
    // MARK: Long Tap Action
    @objc func longTap(sender: UIGestureRecognizer) {
        print("Long tap")
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            
            let longitude = locationOnMap.longitude
            let latitude = locationOnMap.latitude
            self.savePin(longitude: longitude, latitude: latitude)
            
            VirtualTouristAPI.getPhotos(latitude: latitude, longitude: longitude) { (data, error) in
                if let data = data {
                    self.savePhotos(data: data as NSData)
                }
            } ifNoPhotosDo: {
                print("No Photos")
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            mapView.addAnnotation(annotation)
        }
    }

    
    // MARK: MapView
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let annotation = mapView.selectedAnnotations[0]
        let latitude = annotation.coordinate.latitude
        let longitude = annotation.coordinate.longitude
        
        let pin = getPin(latitude: latitude, longitude: longitude)
        
        if let pin = pin {
            performSegue(withIdentifier: "segue", sender: pin)
        } else {
            fatalError("Cannot perform this location.")
        }
        
    }
    
    
    // MARK: Getting location by coordinates
    func getPin(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> Pin? {
        for pin in pins {
            if (pin.latitude == latitude) && (pin.longitude == longitude) {
                return pin
            }
        }
        return nil
    }
    
    
    // MARK: Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CollectionViewController {
            vc.pin = (sender as! Pin)
        }
    }
    
}


extension MapViewController: NSFetchedResultsControllerDelegate {
    
    // MARK: Setting up Fetch request for Pin
    fileprivate func setUpPinFetchRequest(_ appDelegate: AppDelegate) {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            try pins = appDelegate.persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            fatalError("Cannot fetch Pin's data: \(error.localizedDescription)")
        }
        
        for pin in pins {
            let annotation = MKPointAnnotation()
            let latitude = pin.value(forKey: "latitude") as? Double
            let longitude = pin.value(forKey: "longitude") as? Double
            
            if let latitude = latitude, let longitude = longitude {
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
            mapView.addAnnotation(annotation)
        }
    }
    
}


extension MapViewController {
    
    // MARK: Saving pin to Persistent Store
    func savePin(longitude: Double, latitude: Double) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: managedContext)!
        
        let nPin = NSManagedObject(entity: entity, insertInto: managedContext)
        
        nPin.setValue(longitude, forKeyPath: "longitude")
        nPin.setValue(latitude, forKeyPath: "latitude")
        
        do {
            try managedContext.save()
        } catch {
            fatalError("Cannot save pin: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: Saving photos to Persistent Store
    func savePhotos(data: NSData) {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "CollectionOfPhotos", in: managedContext)!
            let nPhoto = NSManagedObject(entity: entity, insertInto: managedContext)
            
            nPhoto.setValue(data, forKeyPath: "photo")
        
            do {
                try managedContext.save()
            } catch {
                fatalError("Could not save: \(error.localizedDescription)")
            }
        }
    }
    
}
