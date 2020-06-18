//
//  Alert.swift
//  GitHubApp
//
//  Created by Konstantins Belcickis on 17/06/2020.
//  Copyright © 2020 Konstantins Belcickis. All rights reserved.
//

import Foundation
import UIKit

class Alert {
    class func showBasic(title: String, message: String, vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc.present(alert, animated: true)
    }
}
