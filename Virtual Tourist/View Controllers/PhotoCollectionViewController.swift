//
//  PhotoCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Anna Solovyeva on 12/10/2020.
//

import UIKit
import CoreData

class PhotoCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: Initializing of variables
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var okButton: UIBarButtonItem!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    var fetchedResultsController: NSFetchedResultsController<Collection>!
    var locations: [Location] = []
    
    
    // MARK: UIView
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
          return
        }
        setUpFetchedResultsController(appDelegate)
        
        newCollectionButton.isEnabled = false
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
    
    
    //MARK: IBActions
    @IBAction func newCollection(sender: Any) {
        
    }
    
    @IBAction func okPressed(sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}


extension PhotoCollectionViewController: NSFetchedResultsControllerDelegate {
    
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
    
    
}


extension PhotoCollectionViewController: UICollectionViewDelegateFlowLayout {
    
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
