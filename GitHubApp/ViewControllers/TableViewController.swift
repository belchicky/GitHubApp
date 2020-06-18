//
//  TableViewController.swift
//  GitHubApp
//
//  Created by Konstantins Belcickis on 10/06/2020.
//  Copyright © 2020 Konstantins Belcickis. All rights reserved.
//

import UIKit
import Foundation

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var myTableView: UITableView = UITableView()
    var repositories: Repositories?
    
    let heightOfHeaderTableView: CGFloat = 300
    let repLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.delegate = self
        myTableView.dataSource = self
        
        myTableView.register(UINib(nibName: "TalbeViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        
        myTableView.frame = view.frame
        view.addSubview(myTableView)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
        repLabel.text = "Repositories found: \(String(describing: repositories!.arrayOfRepositories.count))"
        repLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        repLabel.backgroundColor = UIColor.white
        return repLabel
    }
    
    func tableView(_ tableView: UITableView, heightOfHeaderTableView section: Int) -> CGFloat {
        heightOfHeaderTableView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (repositories?.arrayOfRepositories.count)!
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTableView.dequeueReusableCell(withIdentifier: String(describing: "TableViewCell")) as! TableViewCell
        cell.setCell(with: repositories!.arrayOfRepositories[indexPath.row], index: indexPath.row)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let urlString = repositories!.arrayOfRepositories[indexPath.row].repositoryURL!
        
        DispatchQueue.main.async {
            let nextVC = WebViewController()
            nextVC.modalPresentationStyle = .overFullScreen
            nextVC.urlSting = urlString
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

