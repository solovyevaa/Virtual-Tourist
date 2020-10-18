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
    
    @IBAction func newCollectionPressed(_ sender: Any) {
        deleteAllPhotos()
        getNewPhotos()
        collectionView.reloadData()
    }
    
    
    // MARK: UIView
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getNewPhotos()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        setUpFetchedResultsController(appDelegate)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        setUpFetchedResultsController(appDelegate)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }

}


// MARK: Collection View

extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let photo = fetchedResultsController.object(at: indexPath)
        cell.imageView.image = UIImage(data: photo.photo! as Data)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        deletePhoto(photo: fetchedResultsController.object(at: indexPath))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            
            let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
            
            let itemsPerRow: CGFloat = 3
            let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
            let availableWidth = view.frame.width - paddingSpace
            let widthPerItem = availableWidth / itemsPerRow
            
            return CGSize(width: widthPerItem, height: widthPerItem)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            
            let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0,bottom: 50.0, right: 20.0)
            return sectionInsets
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            
            let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
            return sectionInsets.left
        }
}


// MARK: Setting up FetchedResultsController

extension CollectionViewController: NSFetchedResultsControllerDelegate {
    
    fileprivate func setUpFetchedResultsController(_ appDelegate: AppDelegate) {
        let fetchRequest: NSFetchRequest<CollectionOfPhotos> = CollectionOfPhotos.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "photo", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // TODO: Implement Predicate
        let predicate = NSPredicate(format: "pin == %@", pin!)
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Cannot perform fetch: \(error.localizedDescription)")
        }
        
        collectionView.reloadData()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
        case .update:
            collectionView.reloadItems(at: [indexPath!])
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
            nPhoto.setValue(self.pin, forKeyPath: "pin")
        
            do {
                try managedContext.save()
            } catch {
                fatalError("Could not save: \(error.localizedDescription)")
            }
        }
    }
    
    
}


extension CollectionViewController {
    
    // MARK: Functions to NewCollectionPressed IBAction
    func deleteAllPhotos() {
        if let photosToDelete = self.fetchedResultsController.fetchedObjects {
            for photo in photosToDelete.reversed() {
                deletePhoto(photo: photo)
            }
        }
    }
    
    func deletePhoto(photo: CollectionOfPhotos) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.persistentContainer.viewContext.delete(photo)
        
        do {
            try appDelegate.persistentContainer.viewContext.save()
        } catch {
            print(error)
        }
    }
    
    func getNewPhotos() {
        VirtualTouristAPI.getPhotos(latitude: pin.latitude, longitude: pin.longitude) { (data, error) in
            if let data = data {
                self.savePhotos(data: data as NSData)
            } else {
                fatalError("Cannot save any photos: \(error?.localizedDescription ?? "unknown error")")
            }
        } ifNoPhotosDo: {
            print("No Photos")
        }
    }
    
}
