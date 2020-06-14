//
//  LoginViewController.swift
//  GitHubApp
//
//  Created by Konstantins Belcickis on 24/05/2020.
//  Copyright © 2020 Konstantins Belcickis. All rights reserved.
//

import UIKit
import Kingfisher

final class LoginViewController: UIViewController {
    
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoImageView.kf.setImage(with: URL(string: "https://github.githubassets.com/images/modules/logos_page/GitHub-Logo.png"), placeholder: nil, options: [.transition(.fade(0.7))], progressBlock: nil)
    }
    
    @IBAction func pressLoginButton(_ sender: Any) {
             let vc = SearchViewController()
         self.navigationController?.pushViewController(vc, animated: true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
}
