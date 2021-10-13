//
//  MainViewController.swift
//  GitHubSearch
//
//  Created by David on 2021/10/13.
//

import UIKit

class UserSearchViewController: UICollectionViewController {
  // MARK: - Instance Properties
  var networkClient: GitHubSearchService = GitHubSearchClient.shared
  var dataTask: URLSessionDataTask?
  var users = [User]()
  
  private let searchController = UISearchController(searchResultsController: nil)
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setupSearchBar()
    configureCollectionView()
  }
  
  init() {
    super.init(collectionViewLayout: UICollectionViewFlowLayout())
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Helper Methods
  private func setupSearchBar() {
    navigationItem.searchController = self.searchController
    searchController.searchBar.delegate = self
  }
  
  private func configureCollectionView() {
    navigationItem.title = "Search User"
    navigationController?.navigationBar.prefersLargeTitles = true
    
    collectionView.backgroundColor = .white
  }
  
  func loadUserData(searchText: String, pageNumber: Int = 1) {
    guard dataTask == nil else { return }
    dataTask = networkClient.getUsers(with: searchText, page: pageNumber) { [weak self] users, error in
      guard let self = self else { return }
      self.dataTask = nil
      
      if let allUsers = users, !allUsers.isEmpty {
        self.users.append(contentsOf: allUsers)
        print("self.users: \(self.users)")
      }
    }
  }
}

extension UserSearchViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    loadUserData(searchText: searchText)
  }
}
