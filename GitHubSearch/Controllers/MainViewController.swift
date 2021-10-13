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
  var users = [User]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .red
  }
  
  func loadUserData(searchText: String, pageNumber: Int = 1) {
    guard dataTask == nil else { return }
    dataTask = networkClient.getUsers(with: searchText, page: pageNumber) { [weak self] users, error in
      guard let self = self else { return }
      self.dataTask = nil
      
      if let allUsers = users, !allUsers.isEmpty {
        self.users.append(contentsOf: allUsers)
      }
    }
  }
}
