//
//  PhotosListResponse.swift
//  Virtual Tourist
//
//  Created by Anna Solovyeva on 12/10/2020.
//

import Foundation

struct PhotosListResponse: Codable {
    let page: String
    let pages: String
    let perPage: String
    let total: String
    
    let photo: [PhotoDetailesResponse]
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perPage = "perpage"
        case total
        case photo
    }
    
}
