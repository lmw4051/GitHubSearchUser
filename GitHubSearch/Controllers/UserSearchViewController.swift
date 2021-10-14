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
  
  private let cellId = "CellId"
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
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
    
    viewModel.updateData = { [weak self] () in
      self?.refreshCollectionView()
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
    collectionView.register(SearchResultCell.self, forCellWithReuseIdentifier: cellId)
  }
  
  // MARK: - UICollectionViewDataSource Methods
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.numberOfCells
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchResultCell
    cell.viewModel = viewModel.getCellViewModel(at: indexPath.row)
    return cell
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
