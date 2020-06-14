//
//  Search.swift
//  GitHubApp
//
//  Created by Konstantins Belcickis on 14/06/2020.
//  Copyright © 2020 Konstantins Belcickis. All rights reserved.
//

import Foundation
import UIKit


extension SearchViewController {
    
    func searchRepositoriesRequest() -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = searchRepoPath
        
        var filter = "asc"
        if segment.selectedSegmentIndex == 1 {
            filter = "desc"
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value:  repName.text! + "+language:" + language.text!),
            URLQueryItem(name: "sort", value: "stars"),
            URLQueryItem(name: "order", value: filter)
        ]
        
        guard let url = urlComponents.url else {
            return nil
        }
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = defaultHeaders
        return request
    }
    
    enum BackendError: Error {
        case urlError(reason: String)
        case objectSerialization(reason: String)
    }
    
    enum Result<T> {
        case success(T)
        case fail(Error)
    }
    
    func getRepositories(completionHandler: @escaping (Result<Repositories>) ->Void) {
        guard let urlRequest = searchRepositoriesRequest() else {
            print("url request error")
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest, completionHandler: {
            data, responce, error in
            
            guard error == nil else {
                completionHandler(.fail(error!))
                return
            }
            
            guard let responceData = data else {
                let error = BackendError.objectSerialization(reason: "No data in responce")
                completionHandler(.fail(error)!)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: responceData, options: []) as? [String: Any],
                    let repositories = Repositories(json: json) {
                    completionHandler(.success(repositories))
                } else {
                    let error = BackendError.objectSerialization(reason: "Can't create object from JSON")
                    completionHandler(.fail(error)!)
                }
            } catch {
                completionHandler(.fail(error)!)
                return
            }
        })
        task.resume()
    }
}
