//
//  MockGitHubSearchService.swift
//  GitHubSearchTests
//
//  Created by David on 2021/10/14.
//

@testable import GitHubSearch
import Foundation

class MockGitHubSearchService: GitHubSearchService {
  var getUserCallCount = 0
  var getUserDataTask = URLSessionDataTask()
  var getUserCompletion: (([User]?, Error?) -> Void)!
  
  func getUsers(with query: String, page: Int, completion: @escaping ([User]?, Error?) -> Void) -> URLSessionDataTask {
    getUserCallCount += 1
    getUserCompletion = completion
    return getUserDataTask
  }
}
