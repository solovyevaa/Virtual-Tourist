//
//  PhotoDetailsResposne.swift
//  Virtual Tourist
//
//  Created by Anna Solovyeva on 12/10/2020.
//

import Foundation

struct PhotoDetailesResponse: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let title: String
    let isPublic: String
    let isFriend: String
    let isFamily: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case secret
        case server
        case title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
    }
    var url: URL {return URL(string: "https://live.staticflickr.com/\(server)/\(id)_\(secret)_q.jpg")!}
}
