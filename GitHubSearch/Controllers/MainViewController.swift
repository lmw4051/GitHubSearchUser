//
//  MainViewController.swift
//  GitHubSearch
//
//  Created by David on 2021/10/13.
//

import UIKit

class MainViewController: UIViewController {
  // MARK: - Instance Properties
  var networkClient: GitHubSearchService = GitHubSearchClient.shared
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .red
  }
  
  func loadUserData() {
    
  }
}
