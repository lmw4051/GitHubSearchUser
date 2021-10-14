//
//  UserViewModel.swift
//  GitHubSearch
//
//  Created by David on 2021/10/14.
//

import UIKit

class UserSearchViewModel: NSObject {    
  private var networkClient: GitHubSearchService = GitHubSearchClient.shared
  private var dataTask: URLSessionDataTask?
  private var pageNumber = CommonSetting.startPageNumber
  private var users = [User]()
  
  var isUserDataUpdated: Observable<Bool> = Observable(false)
  var isErrorOccured: Observable<CustomError?> = Observable(nil)
}

extension UserSearchViewModel {
  private func clearUserData() {
    users.removeAll()
    isUserDataUpdated.value = true
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
      
      if let error = error {
        self.isErrorOccured.value = error as? CustomError
        return
      }
      
      if let allUsers = users, !allUsers.isEmpty {
        if pageNumber != CommonSetting.startPageNumber {
          self.users.append(contentsOf: allUsers)
        } else {
          self.users = allUsers
          self.pageNumber = CommonSetting.startPageNumber
        }
        self.isUserDataUpdated.value = true
      } else {
        self.isErrorOccured.value = CustomError.noResultFoundError
      }
    }
  }
}

extension UserSearchViewModel: UICollectionViewDataSource {
  // MARK: - UICollectionViewDataSource Methods
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return users.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellId", for: indexPath) as! SearchResultCell
    cell.user = users[indexPath.item]
    return cell
  }
}
