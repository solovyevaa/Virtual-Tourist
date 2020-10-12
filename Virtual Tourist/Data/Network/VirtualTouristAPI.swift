//
//  VirtualTouristAPI.swift
//  Virtual Tourist
//
//  Created by Anna Solovyeva on 11/10/2020.
//

import Foundation
import MapKit
import OAuthSwift

class VirtualTouristAPI {
    
    static let apiKey = "9a7fc6d36783c384"
    static let apiSecret = "9a7fc6d36783c384"
    
    enum Endpoints {
        static let base = "https://api.flickr.com/services/rest/"
        static let oAuthBase = "https://www.flickr.com/services/oauth/request_token"
        static let apiKeyParam = "&api_key=\(VirtualTouristAPI.apiKey)"
        static let latParam = "&lat="
        static let lonParam = "&lon="
        static let perPageParam = "&per_page="
        static let oauthNonce = "?oauth_nonce="
        static let oauthTimestamp = "&oauth_timestamp="
        static let oauthConsumerKey = "&oauth_consumer_key="
        static let oauthSignatureMethod = "&oauth_signature_method="
        static let oauthVersion = "&oauth_version=2.1.0"
        static let oauthSignature = "&oauth_signature="
        static let oauthCallback = "&oauth_callback="
        
        case searchPhotos (perPage: String, latitude: Double, longitude: Double)
        
        var url: URL {
            return URL(string: stringValue)!
        }
        
        var stringValue: String {
            switch self {
            case .searchPhotos (let perPage, let latitude, let longitude):
                let coordinates = Endpoints.latParam + String(latitude) + Endpoints.lonParam + String(longitude)
                return Endpoints.base + "?method=flickr.photos.search" + Endpoints.apiKeyParam + coordinates + Endpoints.perPageParam + perPage + "&format=json&nojsoncallback=1"
            }
        }
    }
    
}


extension VirtualTouristAPI {
    
    // MARK: Task for GET request
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(VirtualTouristResponse.self, from: data) as Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        
        return task
    }
    
    
    // MARK: Get Photos
    class func getPhotos(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (Data?, Error?) -> Void, ifNoPhotosDo: ((() -> Void))?) {
        let url = Endpoints.searchPhotos(perPage: "30", latitude: latitude, longitude: longitude).url
        print(url)
        
        taskForGETRequest(url: url, responseType: PhotosResponse.self) { (response, error) in
            if let response = response {
                let photoList = response.photos.photo
                
                if photoList.count == 0 {
                    if let ifNoPhotosDo = ifNoPhotosDo {
                        ifNoPhotosDo()
                        return
                    }
                }
                
                for photo in photoList {
                    getImageData(url: photo.url) { (data, error) in
                        if let data = data {
                            completion(data, nil)
                        } else {
                            completion(nil, error)
                        }
                    }
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    
    class func getImageData(url: URL, completion: @escaping (Data?, Error?) -> Void) {
            print(url)
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data else {
                    completion(nil, error)
                    return
                }
                completion(data, nil)
            }
            task.resume()
        }
    
}
