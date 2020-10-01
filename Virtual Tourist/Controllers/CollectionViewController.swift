//
//  CollectionViewController.swift
//  Virtual Tourist
//
//  Created by Anna Solovyeva on 30/09/2020.
//

import UIKit
import CoreData

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var photos: [UIImage] = []
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(photos.count)
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCellViewController", for: indexPath) as! CollectionCellViewController
        let photo = photos[indexPath.row]
        cell.collectionPicture.image = photo
        return cell
    }
    
    
    func imagePicker(pickerType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = pickerType
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let image = info[.originalImage] as? UIImage {
            photos.append(image)
            print(photos)
        }
        collectionView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func appCollection(_ sender: Any) {
        imagePicker(pickerType: .photoLibrary)
    }
    
    
    func save(longitude: Double, latitude: Double) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Collection", in: managedContext)!
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
