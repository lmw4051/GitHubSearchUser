//
//  MainViewController.swift
//  GitHubSearch
//
//  Created by David on 2021/10/13.
//

import UIKit

class UserSearchViewController: UICollectionViewController {
  // MARK: - Instance Properties  
  private let searchController = UISearchController(searchResultsController: nil)  
  var viewModel = UserSearchViewModel()
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    collectionView.dataSource = viewModel
    
    setupSearchBar()
    configureCollectionView()
    
    initViewModelSetup()
  }
  
  private func initViewModelSetup()  {
    viewModel.isUserDataUpdated.bind { [weak self] isFetchedData in
      if isFetchedData {
        self?.refreshCollectionView()
      }
    }
  }
  
  private func refreshCollectionView() {
    DispatchQueue.main.async { [weak self] in
      self?.collectionView.reloadData()
    }
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
    collectionView.register(SearchResultCell.self, forCellWithReuseIdentifier: "CellId")
  }    
}

// MARK: - UISearchBarDelegate Methods
extension UserSearchViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    viewModel.loadUserData(searchText: searchText)
  }
}

// MARK: -  UICollectionViewDelegateFlowLayout Methods
extension UserSearchViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return .init(width: view.frame.width, height: 100)
  }
}
