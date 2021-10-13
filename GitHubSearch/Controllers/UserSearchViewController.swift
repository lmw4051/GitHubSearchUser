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
  private let cellId = "CellId"
  
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
    collectionView.register(SearchResultCell.self, forCellWithReuseIdentifier: cellId)
  }
  
  private func clearUserData() {
    users.removeAll()
    self.collectionView.performBatchUpdates(nil, completion: nil)
  }
  
  func loadUserData(searchText: String, pageNumber: Int = 1) {
    guard dataTask == nil else { return }
    
    if searchText.count <= 0 {
      clearUserData()
      return
    }
    
    dataTask = networkClient.getUsers(with: searchText, page: pageNumber) { [weak self] users, error in
      guard let self = self else { return }
      self.dataTask = nil
      
      if let allUsers = users, !allUsers.isEmpty {
        self.users.append(contentsOf: allUsers)
        print("self.users: \(self.users)")
        self.collectionView.performBatchUpdates(nil, completion: nil)
      }
    }
  }
  
  // MARK: - UICollectionViewDataSource Methods
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return users.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchResultCell
    cell.user = users[indexPath.item]
    return cell
  }
}

// MARK: - UISearchBarDelegate Methods
extension UserSearchViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    loadUserData(searchText: searchText)
  }
}

// MARK: -  UICollectionViewDelegateFlowLayout Methods
extension UserSearchViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return .init(width: view.frame.width, height: 100)
  }
}
