//
//  SceneDelegate.swift
//  Virtual Tourist
//
//  Created by Анна Соловьева on 17/10/2020.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.dataController.load()
        
        let navigationController = window?.rootViewController as! UINavigationController
        let mapViewController = navigationController.topViewController as! MapViewController
        mapViewController.dataController = appDelegate.dataController
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

}

