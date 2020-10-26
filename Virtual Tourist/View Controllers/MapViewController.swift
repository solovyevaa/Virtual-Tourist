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
    var dataController: DataController!
    var pins: [Pin] = []
    var photosForPin: [NSData] = []
    
    
    // MARK: UIView
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        mapView.addGestureRecognizer(longTapGesture)
        
        setUpPinFetchRequest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpPinFetchRequest()
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
                self.photosForPin.append(data! as NSData)
            } ifNoPhotosDo: {
                self.showAlert()
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
            pinView?.glyphImage = UIImage(imageLiteralResourceName: "icon_pin")
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
    
    
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
}


// MARK: Setting up FetchRequest for Pin

extension MapViewController: NSFetchedResultsControllerDelegate {
    
    fileprivate func setUpPinFetchRequest() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            try pins = dataController.viewContext.fetch(fetchRequest)
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
        let managedContext = dataController.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: managedContext)!
        
        let nPin = NSManagedObject(entity: entity, insertInto: managedContext)
        
        pins.append(nPin as! Pin)
        
        nPin.setValue(longitude, forKeyPath: "longitude")
        nPin.setValue(latitude, forKeyPath: "latitude")
        
        do {
            try managedContext.save()
        } catch {
            fatalError("Cannot save pin: \(error.localizedDescription)")
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
            vc.dataController = dataController
            vc.collectionOfPhotos = photosForPin
            photosForPin = []
        }
    }
    
    
    // MARK: UIAlert
    func showAlert() {
        let alert = UIAlertController(title: "No Photos", message: "We couldn't find any photos for this location", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}
