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
        
        let passwordItems = readAllItems(service: self.service)
        if let passItems = passwordItems, !passItems.isEmpty {
            let keys = Array<String>(passItems.keys)
            print(keys)
            authenticateUser(account: keys[0], password: passItems[keys[0]]!)
        }
        
    }
    
    @IBAction func pressLoginButton(_ sender: Any) {
        logIn(account: usernameTextField.text!, password: passwordTextField.text!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    func logIn(account: String, password: String){
        let semaphore = DispatchSemaphore(value: 0)
        let encodedData = String(account + ":" + password).toBase64()
        var request = URLRequest(url: URL(string: "https://api.github.com/user?=")!,timeoutInterval: Double.infinity)
        request.addValue("Basic " + encodedData!, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
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
                            
                            let result = self.savePassword(password: password, service: self.service, account: account)
                            
                            if result, let savedPassword = self.readPassword(service: self.service, account: account) {
                                print("password:\(savedPassword) saved successfully with service name:\(self.service) and account:\(account)")
                            } else {
                                print("can't save password")
                            }
                        } else {
                            Alert.showBasic(title: "Error!", message:  "Login or password error!", vc: self)
                        }
                    }
                } else {
                    print("Error_1")
                    return
                }
            } catch {
                print("Error_2")
                return
            }
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
    }
    
    // MARK: - Private

    private func keychainQuery(service: String, account: String? = nil) -> [String : AnyObject] {
        var query = [String : AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked
        query[kSecAttrService as String] = service as AnyObject
        
        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject
        }
        
        return query
    }

    private func readPassword(service: String, account: String?) -> String? {
        var query = keychainQuery(service: service, account: account)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        
        var queryResult: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &queryResult)
        
        if status != noErr {
            return nil
        }
        
        guard let item = queryResult as? [String : AnyObject],
            let passwordData = item[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: .utf8) else {
                return nil
        }
        return password
    }
    
    private func savePassword(password: String, service: String, account: String?) -> Bool {
        let passwordData = password.data(using: .utf8)
        
        if readPassword(service: service, account: account) != nil {
            var attributesToUpdate = [String : AnyObject]()
            attributesToUpdate[kSecValueData as String] = passwordData as AnyObject
            
            let query = keychainQuery(service: service, account: account)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            return status == noErr
        }
        
        var item = keychainQuery(service: service, account: account)
        item[kSecValueData as String] = passwordData as AnyObject
        let status = SecItemAdd(item as CFDictionary, nil)
        return status == noErr
    }
    
    private func readAllItems(service: String) -> [String : String]? {
        var query = keychainQuery(service: service)
        query[kSecMatchLimit as String] = kSecMatchLimitAll
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        
        var queryResult: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &queryResult)
        if status != noErr {
            return nil
        }
        
        guard let items = queryResult as? [[String : AnyObject]] else {
            return nil
        }
        var passwordItems = [String : String]()
        
        for (index, item) in items.enumerated() {
            guard let passwordData = item[kSecValueData as String] as? Data,
                let password = String(data: passwordData, encoding: .utf8) else {
                    continue
            }
            
            if let account = item[kSecAttrAccount as String] as? String {
                passwordItems[account] = password
                continue
            }
            
            let account = "empty account \(index)"
            passwordItems[account] = password
        }
        return passwordItems
    }
    
    func authenticateUser(account: String, password: String) {
        
        if #available(iOS 8.0, *, *) {
            let authenticationContext = LAContext()
            setupAuthenticationContext(context: authenticationContext)
            
            let reason = "Fast and safe authentication in your app"
            var authError: NSError?
            
            if authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                authenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                    [unowned self] success, evaluateError in
                    if success {
                        // Пользователь успешно прошел аутентификацию
                        self.logIn(account: account, password: password)
                        self.startMainApplicationFlow()
                    } else {
                        // Пользователь не прошел аутентификацию
                        if let error = evaluateError {
                            print(error.localizedDescription)
                        }
                    }
                }
            } else {
                // Не удалось выполнить проверку на использование биометрических данных или пароля для аутентификации
                if let error = authError {
                    print(error.localizedDescription)
                }
            }
        } else {
            // Более рання версия iOS macOS
        }
    }
    func startMainApplicationFlow() {
        print("Main application flow started")
    }
    
    func setupAuthenticationContext(context: LAContext) {
        context.localizedReason = "Use for fast and safe authentication in your app"
        context.localizedCancelTitle = "Cancel"
        context.localizedFallbackTitle = "Enter password"
        
    }
    
    private func deletePassword(service: String, account: String?) -> Bool {
        let item = keychainQuery(service: service, account: account)
        let status = SecItemDelete(item as CFDictionary)
        return status == noErr
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
