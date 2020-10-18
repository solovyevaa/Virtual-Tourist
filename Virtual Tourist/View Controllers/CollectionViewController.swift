//
//  CollectionViewController.swift
//  Virtual Tourist
//
//  Created by Анна Соловьева on 17/10/2020.
//

import UIKit
import MapKit
import CoreData

class CollectionViewController: UIViewController {
    
    // MARK: Initializing of variables
    @IBOutlet weak var okButton: UIBarButtonItem!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    var fetchedResultsController: NSFetchedResultsController<CollectionOfPhotos>!
    var pin: Pin!
    
    
    // MARK: IBActions
    @IBAction func okPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: UIView
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        setUpFetchedResultsController(appDelegate)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        setUpFetchedResultsController(appDelegate)
        
        VirtualTouristAPI.getPhotos(latitude: pin.latitude, longitude: pin.longitude) { (data, error) in
            if let data = data {
                self.savePhotos(data: data as NSData)
            }
        } ifNoPhotosDo: {
            print("No Photos")
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        fetchedResultsController = nil
    }

}


extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let photo = fetchedResultsController.object(at: indexPath)
        cell.imageView.image = UIImage(data: photo.photo! as Data)
        
        return cell
    }
    
    
}


extension CollectionViewController: NSFetchedResultsControllerDelegate {
    
    // MARK: Setting up FetchedResultsController
    fileprivate func setUpFetchedResultsController(_ appDelegate: AppDelegate) {
        let fetchRequest: NSFetchRequest<CollectionOfPhotos> = CollectionOfPhotos.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "photo", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // TODO: Implement Predicate
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Cannot perform fetch: \(error.localizedDescription)")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
        default:
            break
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
