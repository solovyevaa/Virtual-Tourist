//
//  FlickrGetPhotosResponse.swift
//  Virtual Tourist
//
//  Created by Анна Соловьева on 17/10/2020.
//

import Foundation

struct FlickrGetPhotosResponse: Codable {
    
    let photos: FlickrListResponse
    let stat: String
    
}
