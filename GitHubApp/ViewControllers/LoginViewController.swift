//
//  LoginViewController.swift
//  GitHubApp
//
//  Created by Konstantins Belcickis on 24/05/2020.
//  Copyright © 2020 Konstantins Belcickis. All rights reserved.
//

import UIKit
import Kingfisher
import LocalAuthentication

final class LoginViewController: UIViewController {
    
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    
    let service = "github"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoImageView.kf.setImage(with: URL(string: "https://github.githubassets.com/images/modules/logos_page/GitHub-Logo.png"), placeholder: nil, options: [.transition(.fade(0.7))], progressBlock: nil)
    }
    
    @IBAction func pressLoginButton(_ sender: Any) {
        logIn(account: usernameTextField.text!, password: passwordTextField.text!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    func logIn(account: String, password: String) {
        let encodedData = String(account + ":" + password).toBase64()
        var request = URLRequest(url: URL(string: "https://api.github.com/user?=")!,timeoutInterval: Double.infinity)
        request.addValue("Basic " + encodedData!, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data else {
                return
            }          
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    
                    DispatchQueue.main.async {
                        let vc = SearchViewController()
                        vc.modalPresentationStyle = .overFullScreen
                        if let avatarURL = json["avatar_url"] as? String, let login = json["login"] as? String {
                            vc.avatarURL = avatarURL
                            vc.username = login
                            self.navigationController?.pushViewController(vc, animated: true)
                        } else {
                            Alert.showBasic(title: "Error!", message:  "Login or password error!", vc: self)
                        }
                    }
                } else {
                    return
                }
            } catch {
                return
            }
        }
        task.resume()
    }
}

extension String {
    func toBase64() -> String? {
        guard let data = self.data(using: String.Encoding.utf8) else {
            return nil
        }
        
        return data.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }
}
