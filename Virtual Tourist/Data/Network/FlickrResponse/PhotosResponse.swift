//
//  PhotosResponse.swift
//  Virtual Tourist
//
//  Created by Anna Solovyeva on 12/10/2020.
//

import Foundation

struct PhotosResponse: Codable {
    let photos: PhotosListResponse
    let stat: String
}
