//
//  TableViewCell.swift
//  GitHubApp
//
//  Created by Konstantins Belcickis on 10/06/2020.
//  Copyright © 2020 Konstantins Belcickis. All rights reserved.
//

import UIKit
import Foundation
import Kingfisher

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var repName: UILabel!
    @IBOutlet weak var repDescription: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var authorName: UILabel!
    
    func setCell(with repository: Repositories.Repository, index: Int) {
        repName.text = repository.name
        repDescription.text = repository.description
        avatar.kf.setImage(with: repository.avatarURL)
        authorName.text = repository.ownnerName
        repDescription.sizeToFit()
        self.selectionStyle = .default
    }
    
}
