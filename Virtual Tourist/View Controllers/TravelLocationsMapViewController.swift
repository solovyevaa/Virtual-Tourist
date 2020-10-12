//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Anna Solovyeva on 11/10/2020.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController {
    
    // MARK: Initialiazaing of variables
    @IBOutlet weak var mapView: MKMapView!
    var locations: [Location] = []
    
    
    // MARK: UIView
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        mapView.addGestureRecognizer(longTapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
          return
        }
        setUpFetchRequest(appDelegate)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

}


extension TravelLocationsMapViewController {
    
    // MARK: Setting up Fetch Request
    fileprivate func setUpFetchRequest(_ appDelegate: AppDelegate) {
        let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
        
        do {
            try locations = appDelegate.persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            fatalError("Cannot perform fetch: \(error.localizedDescription)")
        }
        
        for location in locations {
            let annotation = MKPointAnnotation()
            let latitude = location.value(forKey: "latitude") as? Double
            let longitude = location.value(forKey: "longitude") as? Double
            
            VirtualTouristAPI.getPhotos(latitude: latitude!, longitude: longitude!) { (data, error) in
                if let error = error {
                    print("Request failed: \(error.localizedDescription)")
                } else {
                    print("Succeful Request")
                }
            } ifNoPhotosDo: {
                print("No photos")
            }

            
            if let latitude = latitude, let longitude = longitude {
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
            mapView.addAnnotation(annotation)
        }
    }
    
    
    // MARK: Saving context to Persistent Container
    func save(longitude: Double, latitude: Double) {
      guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
        return
      }
      
      let managedContext =
        appDelegate.persistentContainer.viewContext
      let entity =
        NSEntityDescription.entity(forEntityName: "Location",
                                   in: managedContext)!
      let nLocation = NSManagedObject(entity: entity,
                                   insertInto: managedContext)
      nLocation.setValue(longitude, forKeyPath: "longitude")
      nLocation.setValue(latitude, forKeyPath: "latitude")
        
      do {
        try managedContext.save()
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
}


extension TravelLocationsMapViewController: MKMapViewDelegate {
    
    // MARK: Map View
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
        
        
    /*func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let controller = storyboard?.instantiateViewController(identifier: "CollectionViewController") as! CollectionViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }*/
        
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // TODO: IMPLEMENT RIGHT SIDE BUTTON
    }
    
}


extension TravelLocationsMapViewController {
    
    // MARK: Handle Requests
    func handleRequestTokenResponse(success: Bool, error: Error?) {
        if success {
            print("Request is successful")
        } else {
            print("Request failed")
        }
    }
    
}
