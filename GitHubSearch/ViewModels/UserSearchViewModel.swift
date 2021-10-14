//
//  UserViewModel.swift
//  GitHubSearch
//
//  Created by David on 2021/10/14.
//

import Foundation

// MARK: - DataCellViewModel
struct DataCellViewModel {
  let login: String
  let score: Double
  let avatar_url: String
  
  init(user: User) {
    self.login = user.login
    self.score = user.score
    self.avatar_url = user.avatar_url
  }
}

class UserSearchViewModel {
  private var networkClient: GitHubSearchService = GitHubSearchClient.shared
  private var dataTask: URLSessionDataTask?
  private var pageNumber = CommonSetting.startPageNumber
  private var users = [User]()
  
  var isUserDataUpdated: Observable<Bool> = Observable(false)
  var isErrorOccured: Observable<CustomError?> = Observable(nil)
  
  var numberOfCells: Int {
    return cellViewModels.count
  }
  
  private var cellViewModels = [DataCellViewModel]() {
    didSet {
      self.updateData?()
    }
  }
  
  var updateData: (() -> ())?
  
  private func clearUserData() {
    cellViewModels.removeAll()
    isUserDataUpdated.value = true
  }
  
  private func processFetchedData(_ users: [User]) {
    self.cellViewModels = users.map { DataCellViewModel(user: $0) }
  }
  
  func getCellViewModel(at index: NSInteger) -> DataCellViewModel {
    return cellViewModels[index]
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
          self.processFetchedData(self.users)
        } else {
          self.users = allUsers
          self.processFetchedData(self.users)
          self.pageNumber = CommonSetting.startPageNumber
        }
        self.isUserDataUpdated.value = true
      } else {
        self.isErrorOccured.value = CustomError.noResultFoundError
      }
    }
  }
}
