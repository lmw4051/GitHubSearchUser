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
  var dataTask: URLSessionDataTask?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .red
  }
  
  func loadUserData() {
    guard dataTask == nil else { return }
    dataTask = networkClient.getUsers(with: "a", page: 1) { searchResult, error in
      self.dataTask = nil
    }
  }
}
