//
//  FlickrGetPhotosResponse.swift
//  Virtual Tourist
//
//  Created by Anna Solovyeva on 12/10/2020.
//

import Foundation

struct FlickrGetPhotosResponse: Codable {
    
    let photos: FlickrListResponse
    let stat: String
    
}
