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
  private var pageNumber = CommonSetting.startPageNumber
  private var users = [User]()
  
  var isUserDataUpdated: Observable<Bool> = Observable(false)
  var isErrorOccured: Observable<CustomError?> = Observable(nil)
  
  var isLoading: Bool = false
  var searchStr: String?
  
  var numberOfCells: Int {
    return cellViewModels.count
  }
  
  private var cellViewModels = [DataCellViewModel]() {
    didSet {
      self.updateData?()
    }
  }
  
  var updateData: (() -> ())?
  
  func resetUserData() {
    cellViewModels.removeAll()
    pageNumber = CommonSetting.startPageNumber
    isUserDataUpdated.value = true
  }
  
  private func processFetchedData(_ users: [User]) {
    self.cellViewModels = users.map { DataCellViewModel(user: $0) }
  }
  
  func getCellViewModel(at index: NSInteger) -> DataCellViewModel {
    return cellViewModels[index]
  }
  
  func loadUserData(searchText: String) {
    if searchText.count <= 0 {
      resetUserData()
      return
    }
    
    isLoading = true
    searchStr = searchText
    
    networkClient.getUsers(with: searchText, page: pageNumber) { [weak self] users, response, error in
      guard let self = self else { return }
      
      self.isLoading = false
      
      if let error = error {
        self.isErrorOccured.value = error
        return
      }
      
      if let allUsers = users, !allUsers.isEmpty {
        if self.pageNumber != CommonSetting.startPageNumber {
          self.users.append(contentsOf: allUsers)
          self.processFetchedData(self.users)
        } else {
          self.users = allUsers
          self.processFetchedData(self.users)
          self.pageNumber = CommonSetting.startPageNumber
        }
        self.isUserDataUpdated.value = true
        self.parseHeader(response: response)
      } else {
        self.isErrorOccured.value = CustomError.noResultFoundError
      }
    }
  }
  
  func parseHeader(response: HTTPURLResponse?) {
    if let httpResponse = response {
      if let linkHeader = httpResponse.allHeaderFields["Link"] as? String {
        print("linkHeader:", linkHeader)
        
        let links = linkHeader.components(separatedBy: ",")
        
        var dictionary: [String: String] = [:]
        links.forEach {
          let components = $0.components(separatedBy:"; ")
          let cleanPath = components[0].trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
          dictionary[components[1]] = cleanPath
        }
        
        if let nextPagePath = dictionary["rel=\"next\""] {
          print("nextPagePath: \(nextPagePath)")
          if let nextPage = nextPagePath.components(separatedBy: "=").last {
            print(nextPage)
            self.pageNumber = Int(nextPage) ?? 0
          }
        }
      }
    }
  }
}
