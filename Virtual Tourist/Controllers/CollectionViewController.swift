//
//  CollectionViewController.swift
//  Virtual Tourist
//
//  Created by Anna Solovyeva on 30/09/2020.
//

import UIKit
import CoreData

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var photos: [NSManagedObject] = []
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Collection")
        
        do {
            photos = try managedContext.fetch(fetchRequest)
            print(photos)
        } catch let error as NSError {
            print("Could not retrieve data. \(error), \(error.userInfo)")
        }
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
        cell.collectionPicture.image = UIImage(data: photo.value(forKeyPath: "photo") as! Data)
        return cell
    }
    
    
    func imagePicker(pickerType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = pickerType
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let image = info[.originalImage] as? NSData {
            self.save(photo: image)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func appCollection(_ sender: Any) {
        imagePicker(pickerType: .photoLibrary)
    }
    
    
    func save(photo: NSData) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Collection", in: managedContext)!
        let newPhoto = NSManagedObject(entity: entity, insertInto: managedContext)
        newPhoto.setValue(photo, forKey: "photo")
        
        do {
            try? managedContext.save()
            photos.append(newPhoto)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    
}
