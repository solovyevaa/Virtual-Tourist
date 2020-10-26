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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var dataController: DataController!
    var collectionOfPhotos: [NSData] = []
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
        
        for photo in collectionOfPhotos {
            savePhotos(data: photo)
        }
        
        setUpFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicator.startAnimating()
        newCollectionButton.isEnabled = false
        okButton.isEnabled = false
        
        setUpFetchedResultsController()
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
        
        newCollectionButton.isEnabled = true
        okButton.isEnabled = true
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        
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


extension CollectionViewController: NSFetchedResultsControllerDelegate {
    
    // MARK: Setting up FetchedResultsController
    fileprivate func setUpFetchedResultsController() {
        let fetchRequest: NSFetchRequest<CollectionOfPhotos> = CollectionOfPhotos.fetchRequest()
        fetchRequest.sortDescriptors = []
        
        let predicate = NSPredicate(format: "pin == %@", pin!)
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
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
            
            let managedContext = self.dataController.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "CollectionOfPhotos", in: managedContext)!
            let nPhoto = NSManagedObject(entity: entity, insertInto: managedContext)
            
            nPhoto.setValue(data, forKeyPath: "photo")
            nPhoto.setValue(self.pin, forKeyPath: "pin")
        
            do {
                try managedContext.save()
            } catch {
                fatalError("Cannot save photos: \(error.localizedDescription)")
            }
        }
    }
    
}


// MARK: Getting and Deleting photos

extension CollectionViewController {
    
    func deleteAllPhotos() {
        if let photosToDelete = self.fetchedResultsController.fetchedObjects {
            for photo in photosToDelete.reversed() {
                deletePhoto(photo: photo)
            }
        }
    }
    
    func deletePhoto(photo: CollectionOfPhotos) {
        dataController.viewContext.delete(photo)
        
        do {
            try dataController.viewContext.save()
        } catch {
            fatalError("Cannot delete photos: \(error.localizedDescription)")
        }
    }
    
    func getNewPhotos() {
        okButton.isEnabled = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        VirtualTouristAPI.getPhotos(latitude: pin.latitude, longitude: pin.longitude) { (data, error) in
            if let data = data {
                self.savePhotos(data: data as NSData)
            } else {
                fatalError("Cannot get new photos: \(error?.localizedDescription ?? "unknown error")")
            }
        } ifNoPhotosDo: {
            self.showAlert()
        }
    }
    
}


extension CollectionViewController {
    
    // MARK: UIAlert
    func showAlert() {
        let alert = UIAlertController(title: "No Photos", message: "We couldn't find any photos for this location", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
        okButton.isEnabled = true
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
}
