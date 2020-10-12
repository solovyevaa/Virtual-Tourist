//
//  FlickrListResponse.swift
//  Virtual Tourist
//
//  Created by Anna Solovyeva on 12/10/2020.
//

import Foundation

struct FlickrListResponse: Codable {
    
    let page: Int
    let pages: Int
    let perPage: Int
    let total: String
    let photo: [FlickrPhotoResponse]
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perPage = "perpage"
        case total
        case photo
    }
    
}
