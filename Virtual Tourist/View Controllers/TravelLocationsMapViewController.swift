//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Anna Solovyeva on 11/10/2020.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: Initialiazaing of variables
    @IBOutlet weak var mapView: MKMapView!
    var fetchedResultsController: NSFetchedResultsController<Collection>!
    var locations: [Location] = []
    
    
    // MARK: UIView
    override func viewDidLoad() {
        super.viewDidLoad()
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        mapView.addGestureRecognizer(longTapGesture)
        
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
          return
        }
        setUpFetchRequest(appDelegate)
        setUpFetchedResultsController(appDelegate)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
          return
        }
        setUpFetchRequest(appDelegate)
        setUpFetchedResultsController(appDelegate)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
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
            
            // MARK: Getting photos from Flickr
            VirtualTouristAPI.getPhotos(latitude: latitude!, longitude: longitude!) { (data, error) in
                if let data = data {
                    self.savePhotos(data: data as NSData)
                } else {
                    fatalError("Cannot save photos: \(error?.localizedDescription ?? "unknown error")")
                }
            } ifNoPhotosDo: {
                print("No Photos")
            }

            
            if let latitude = latitude, let longitude = longitude {
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                annotation.title = "Collection of photos"
            }
            mapView.addAnnotation(annotation)
        }
    }
    
    
    // MARK: Setting up FetchedResultsController
    fileprivate func setUpFetchedResultsController(_ appDelegate: AppDelegate) {
        let fetchRequest: NSFetchRequest<Collection> = Collection.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "photo", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        for location in locations {
            let predicate = NSPredicate(format: "location == %@", location)
            fetchRequest.predicate = predicate
        }
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Cannot perform fetch: \(error.localizedDescription)")
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
    
    
    // MARK: Saving photos to Persistent Container
    func savePhotos(data: NSData) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
            }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Collection", in: managedContext)!
        let nPhoto = NSManagedObject(entity: entity, insertInto: managedContext)
        
        nPhoto.setValue(data, forKeyPath: "photo")
        
        do {
            try managedContext.save()
        } catch {
            fatalError("Could not save: \(error.localizedDescription)")
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
            let reuseId = "pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView!.pinTintColor = .red
            }
            else {
                pinView!.annotation = annotation
            }
            
            return pinView
        }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "PhotoCollectionViewController") as! PhotoCollectionViewController
        present(controller, animated: true, completion: nil)
    }
    
    
    // MARK: Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        if let vc = segue.destination as? PhotoCollectionViewController {
            vc.locations = locations
            vc.fetchedResultsController = fetchedResultsController
            
        }
    }
    
}
