//
//  FlickrPhotoResponse.swift
//  Virtual Tourist
//
//  Created by Анна Соловьева on 17/10/2020.
//

import Foundation

struct FlickrPhotoResponse: Codable {
    
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let isPublic: Int
    let isFriend: Int
    let isFamily: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case secret
        case server
        case farm
        case title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
    }
    
    var url: URL {return URL(string: "https://live.staticflickr.com/\(server)/\(id)_\(secret)_q.jpg")!}
    
}
