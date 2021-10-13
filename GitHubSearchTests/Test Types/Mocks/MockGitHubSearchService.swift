//
//  MockGitHubSearchService.swift
//  GitHubSearchTests
//
//  Created by David on 2021/10/14.
//

@testable import GitHubSearch
import Foundation

class MockGitHubSearchService: GitHubSearchService {
  var getSearchResultCallCount = 0
  var getSearchResultDataTask = URLSessionDataTask()
  var getSearchResultCompletion: ((SearchResult?, Error?) -> Void)!
  
  func getUsers(with query: String, page: Int, completion: @escaping (SearchResult?, Error?) -> Void) -> URLSessionDataTask {
    getSearchResultCallCount += 1
    getSearchResultCompletion = completion
    return getSearchResultDataTask
  }
}
