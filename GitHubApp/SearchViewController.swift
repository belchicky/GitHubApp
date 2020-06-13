//
//  SearchViewController.swift
//  GitHubApp
//
//  Created by Konstantins Belcickis on 26/05/2020.
//  Copyright © 2020 Konstantins Belcickis. All rights reserved.
//
import UIKit
import Kingfisher

class SearchViewController: UIViewController {
    
    var helloLabel = UILabel()
    var userAvatar = UIImageView()
    var searchRepLabel = UILabel()
    var repName = UITextField()
    var language = UITextField()
    var segment = UISegmentedControl(items: ["ascended", "descended"])
    var startButton = UIButton()
    
    private let headers = ["Accept" : "application/vnd.github.mercy-preview+json"]
    private let scheme = "https"
    private let host = "api.github.com"
    private let hostPath = "https://api.github.com"
    private let searchRepoPath = "/search/repositories"
    
    var avatarURL: String!
    var username: String!
    
    private let defaultHeaders = [
        "Content-Type" : "application/json",
        "Accept" : "application/vnd.github.v3+json"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        searchViewConfiger()
        helloLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(helloLabel)
        view.addSubview(userAvatar)
        view.addSubview(searchRepLabel)
        view.addSubview(repName)
        view.addSubview(language)
        view.addSubview(segment)
        view.addSubview(startButton)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
        
        view.setNeedsUpdateConstraints()
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    func searchViewConfiger() {
        
        userAvatar.kf.setImage(with: URL(string: "https://i.ya-webdesign.com/images/avatar-icon-png-6.png"))
        userAvatar.translatesAutoresizingMaskIntoConstraints = false
        
        helloLabel.text = "Hello"
        helloLabel.translatesAutoresizingMaskIntoConstraints = false
        helloLabel.textAlignment = .center
        helloLabel.font = helloLabel.font.withSize(19.0)
        
        searchRepLabel.text = "Search repository"
        searchRepLabel.translatesAutoresizingMaskIntoConstraints = false
        searchRepLabel.textAlignment = .center
        
        repName.placeholder = "Repository search"
        repName.borderStyle = .roundedRect
        repName.translatesAutoresizingMaskIntoConstraints = false
        repName.layer.cornerRadius = 6.0
        repName.clearsOnBeginEditing = true
        
        language.placeholder = "Language"
        language.borderStyle = .roundedRect
        language.translatesAutoresizingMaskIntoConstraints = false
        language.layer.cornerRadius = 6.0
        language.clearsOnBeginEditing = true
        
        startButton.setTitle("Start search", for: .normal)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.setTitleColor(.systemBlue, for: .normal)
        startButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.selectedSegmentIndex = 0
    }
    
    @objc func buttonPressed(sender: UIButton!) {
        getRepositories() {
            result in
            
            switch result {
                
            case .success(let repositories):
                print(repositories)
                DispatchQueue.main.async {
                    let nextVC = TableViewController()
                    nextVC.modalPresentationStyle = .overFullScreen
                    nextVC.repositories = repositories
                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
                
            case .fail(let error):
                print(error)
            }
        }
        
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        helloLabel.widthAnchor.constraint(equalToConstant: 250.0).isActive = true
        helloLabel.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        helloLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100.0).isActive = true
        helloLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0.0).isActive = true
        
        userAvatar.topAnchor.constraint(equalTo: helloLabel.bottomAnchor, constant: 30.0).isActive = true
        userAvatar.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
        userAvatar.heightAnchor.constraint(equalToConstant: 150.0).isActive = true
        userAvatar.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0.0).isActive = true
        
        searchRepLabel.topAnchor.constraint(equalTo: userAvatar.bottomAnchor, constant: 30.0).isActive = true
        searchRepLabel.widthAnchor.constraint(equalToConstant: 200.0).isActive = true
        searchRepLabel.heightAnchor.constraint(equalToConstant: 30.0 ).isActive = true
        searchRepLabel.centerXAnchor.constraint(equalTo: userAvatar.centerXAnchor, constant: 0.0).isActive = true
        
        repName.widthAnchor.constraint(equalToConstant: 270.0).isActive = true
        repName.heightAnchor.constraint(equalToConstant: 30).isActive = true
        repName.centerXAnchor.constraint(equalTo: searchRepLabel.centerXAnchor).isActive = true
        repName.topAnchor.constraint(equalTo: searchRepLabel.bottomAnchor, constant: 10.0).isActive = true
        
        language.widthAnchor.constraint(equalToConstant: 270.0).isActive = true
        language.heightAnchor.constraint(equalToConstant: 30).isActive = true
        language.centerXAnchor.constraint(equalTo: repName.centerXAnchor).isActive = true
        language.topAnchor.constraint(equalTo: repName.bottomAnchor, constant: 10.0).isActive = true
        
        segment.widthAnchor.constraint(equalToConstant: 270.0).isActive = true
        segment.heightAnchor.constraint(equalToConstant: 30).isActive = true
        segment.centerXAnchor.constraint(equalTo: repName.centerXAnchor).isActive = true
        segment.topAnchor.constraint(equalTo: language.bottomAnchor, constant: 10.0).isActive = true
        
        startButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        startButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        startButton.centerXAnchor.constraint(equalTo: repName.centerXAnchor).isActive = true
        startButton.topAnchor.constraint(equalTo: segment.bottomAnchor, constant: 20.0).isActive = true
    }

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
        print("search request url:\(url)")
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
    
    let sharedSession = URLSession.shared
    
   func getRepositories(completionHandler: @escaping (Result<Repositories>) ->Void) {
            guard let urlRequest = searchRepositoriesRequest() else {
                print("url request error")
                return
            }
            
            let session = URLSession.shared
            let task = session.dataTask(with: urlRequest, completionHandler: {
                data, responce, error in
//
//                guard error == nil else {
//                    completionHandler(.fail(error!))
//                    return
//                }
                
                guard let responceData = data else {
//                    let error = BackendError.objectSerialization(reason: "No data in responce")
//                    completionHandler(.fail(error)!)
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: responceData, options: []) as? [String: Any],
                        let repositories = Repositories(json: json) {
                        completionHandler(.success(repositories))
                    } else {
//                        let error = BackendError.objectSerialization(reason: "Can't create object from JSON")
//                        completionHandler(.fail(error)!)
                    }
                } catch {
//                    completionHandler(.fail(error)!)
                    return
                }
            })
            task.resume()
        }
        
    }
