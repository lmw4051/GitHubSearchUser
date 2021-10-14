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
  
  let noUserFoundView: UIView = {
    let v = UIView()
    v.backgroundColor = .clear
    v.alpha = 1
    return v
  }()
  
  let noUserLabel: UILabel = {
    let label = UILabel()
    label.text = "No User Found"
    label.textColor = .darkGray
    return label
  }()
  
  let errorMessageView: UIView = {
    let v = UIView()
    v.backgroundColor = .black
    v.alpha = 0.5
    return v
  }()
  
  let errorMessageLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 12)
    label.text = "Something went wrong, try again in a minute later"
    label.textColor = .white
    return label
  }()
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    setupSearchBar()
    configureCollectionView()
    configureMessageViews()
    hideMessageViews()
    initViewModelSetup()
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
  
  private func configureMessageViews() {
    self.view.addSubview(noUserFoundView)
    noUserFoundView.fillSuperviewSafeAreaLayoutGuide()
    
    noUserFoundView.addSubview(noUserLabel)
    noUserLabel.centerInSuperview()
    
    self.view.addSubview(errorMessageView)
    errorMessageView.centerInSuperview()
    errorMessageView.constrainHeight(constant: 70)
    errorMessageView.constrainWidth(constant: self.view.frame.width)
    
    errorMessageView.addSubview(errorMessageLabel)
    errorMessageLabel.centerInSuperview()
  }
  
  private func hideMessageViews() {
    noUserFoundView.isHidden = true
    errorMessageView.isHidden = true
  }
  
  private func initViewModelSetup()  {
    viewModel.isUserDataUpdated.bind { [weak self] isFetchedData in
      if isFetchedData {
        self?.refreshCollectionView()
      }
    }
    
    viewModel.isErrorOccured.bind { [weak self] error in
      guard let error = error else { return }
      switch error {
      case CustomError.httpResponseError,
           CustomError.jsonDecoingError, CustomError.dataError,
           CustomError.httpServerError:
        self?.showHttpError(show: true)
      case CustomError.noResultFoundError:
        self?.showNoUserData()
      }
    }
    
    viewModel.updateData = { [weak self] () in
      self?.refreshCollectionView()
    }
  }
  
  private func refreshCollectionView() {
    DispatchQueue.main.async { [weak self] in
      self?.noUserFoundView.isHidden = true
      self?.collectionView.isHidden = false
      self?.collectionView.reloadData()
    }
  }
  
  private func showNoUserData() {
    DispatchQueue.main.async { [weak self] in
      self?.noUserFoundView.isHidden = false
      self?.collectionView.isHidden = true
    }
  }
  
  func showHttpError(show: Bool = false) {
    DispatchQueue.main.async {  [weak self] in
      UIView.animate(withDuration: 0.3, animations: {
        self?.errorMessageView.alpha = 0.5
      }) { (finished) in
        self?.errorMessageView.isHidden = !show
      }
    }
    
    if show {
      DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
        self?.errorMessageView.isHidden = true
      }
    }
  }
  
  // MARK: - UICollectionViewDataSource Methods
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.numberOfCells
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchResultCell
    cell.viewModel = viewModel.getCellViewModel(at: indexPath.row)
    
    if indexPath.item == viewModel.numberOfCells - 1 {
      if !viewModel.isLoading {
        viewModel.loadUserData(searchText: viewModel.searchStr ?? "")
      }
    }
    return cell
  }
}

// MARK: - UISearchBarDelegate Methods
extension UserSearchViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    viewModel.resetUserData()
    viewModel.loadUserData(searchText: searchText)
  }
  
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    viewModel.isLoading = false
  }
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {    
    viewModel.isLoading = true
  }
}

// MARK: -  UICollectionViewDelegateFlowLayout Methods
extension UserSearchViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return .init(width: view.frame.width, height: 100)
  }
}
