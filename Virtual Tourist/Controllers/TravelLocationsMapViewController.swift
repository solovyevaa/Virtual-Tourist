//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Anna Solovyeva on 23/09/2020.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var locations: [NSManagedObject] = []
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Location")
        
        do {
            locations = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not retrieve data. \(error), \(error.userInfo)")
        }
        
        for location in locations {
            let annotation = MKPointAnnotation()
            let latitude = location.value(forKey: "latitude") as? Double
            let longitude = location.value(forKey: "longitude") as? Double
            
            if let latitude = latitude, let longitude = longitude {
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
            mapView.addAnnotation(annotation)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        mapView.addGestureRecognizer(longTapGesture)
    }
    
    
    @objc func longTap(sender: UIGestureRecognizer) {
        print("Long tap")
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            let longitude = locationOnMap.longitude
            let latitude = locationOnMap.latitude
            self.save(longitude: longitude, latitude: latitude)
        }
    }
    
    func save(longitude: Double, latitude: Double) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Location", in: managedContext)!
        let newLocation = NSManagedObject(entity: entity, insertInto: managedContext)
        newLocation.setValue(longitude, forKey: "longitude")
        newLocation.setValue(latitude, forKey: "latitude")
        
        do {
            try? managedContext.save()
            locations.append(newLocation)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
}


extension TravelLocationsMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else {
            print("MKPointannotation doesn't exist")
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            // TODO: CHANGE PIN VIEW TO SHOW COLLECTION OF PHOTOS
            pinView?.rightCalloutAccessoryView = UIButton(type: .infoDark)
            pinView?.pinTintColor = .red
        } else {
                pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let controller = storyboard?.instantiateViewController(identifier: "CollectionViewController") as! CollectionViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // TODO: IMPLEMENT RIGHT SIDE BUTTON
    }
    
}
