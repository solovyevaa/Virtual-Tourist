//
//  FlickrGeneralResponse.swift
//  Virtual Tourist
//
//  Created by Anna Solovyeva on 12/10/2020.
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
