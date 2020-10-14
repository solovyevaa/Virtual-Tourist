//
//  PhotoCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Anna Solovyeva on 12/10/2020.
//

import UIKit
import CoreData

class PhotoCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var fetchedResultsController: NSFetchedResultsController<Collection>!
    var location: Location!
    
    // MARK: UIView
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
          return
        }
        setUpFetchedResultsController(appDelegate)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
          return
        }
        setUpFetchedResultsController(appDelegate)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        fetchedResultsController = nil
    }
    
    
    // MARK: Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCellCollectionViewCell", for: indexPath) as! PhotoCellCollectionViewCell
        let photo = fetchedResultsController.object(at: indexPath)
        cell.imageView.image = UIImage(data: photo.photo!)
        
        return cell
    }
    
}


extension PhotoCollectionViewController: NSFetchedResultsControllerDelegate {
    
    // MARK: Setting up FetchedResultsController
    fileprivate func setUpFetchedResultsController(_ appDelegate: AppDelegate) {
        let fetchRequest: NSFetchRequest<Collection> = Collection.fetchRequest()
        let predicate = NSPredicate(format: "location == %@", location)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "photo", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Cannot perform fetch: \(error.localizedDescription)")
        }
    }
    
}
