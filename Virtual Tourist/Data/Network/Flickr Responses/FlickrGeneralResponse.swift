//
//  FlickrGeneralResponse.swift
//  Virtual Tourist
//
//  Created by Анна Соловьева on 17/10/2020.
//

import Foundation

struct FlickrGeneralResponse: Codable {
    
    let stat: String
    let code: Int
    let message: String
}

extension FlickrGeneralResponse: LocalizedError {
    var errorDescription: String? {
        return message
    }
}
