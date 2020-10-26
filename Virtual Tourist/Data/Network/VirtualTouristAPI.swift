//
//  VirtualTouristAPI.swift
//  Virtual Tourist
//
//  Created by Анна Соловьева on 17/10/2020.
//

import Foundation
import MapKit

class VirtualTouristAPI {
    
    // MARK: Initializing URL Request
    static let apiKey = "8b0c98378081f676a699ffcd9b3896da"
    
    enum Endpoints {
        static let base = "https://api.flickr.com/services/rest/"
        static let method = "?method=flickr.photos.search"
        static let apiKeyParam = "&api_key=\(VirtualTouristAPI.apiKey)"
        static let lat = "&lat="
        static let lon = "&lon="
        static let perPage = "&per_page="
        static let page = "&page="
        
        case searchPhotos(latitude: Double, longitude: Double, perPage: String, page: String)
        
        var stringValue: String {
            switch self {
            case .searchPhotos(latitude: let latitude, longitude: let longitude, perPage: let perPage, page: let page):
                let coordinates = Endpoints.lat + String(latitude) + Endpoints.lon + String(longitude)
                return Endpoints.base + Endpoints.method + Endpoints.apiKeyParam + coordinates + Endpoints.perPage + perPage + Endpoints.page + page + "&format=json&nojsoncallback=1"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    
    // MARK: Task for GET Request
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
                    let errorResponse = try decoder.decode(FlickrGeneralResponse.self, from: data) as Error
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
    
    
    // MARK: Getting photos from Flickr
    class func getPhotos(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (Data?, Error?) -> Void, ifNoPhotosDo: ((() -> Void))?) {
        
        let url = Endpoints.searchPhotos(latitude: latitude, longitude: longitude, perPage: "30", page: "\(Int.random(in: 0..<6))").url
        print(url)
        
        taskForGETRequest(url: url, responseType: FlickrGetPhotosResponse.self) { (response, error) in
            
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

