//
//  GitHubSearchClient.swift
//  GitHubSearch
//
//  Created by David on 2021/10/13.
//

import Foundation

class GitHubSearchClient {
  let baseURL: URL
  let session: URLSession
  
  init(baseURL: URL,
       session: URLSession) {
    self.baseURL = baseURL
    self.session = session
  }
  
  func getUsers(with query: String,
                page: Int,
                completion: @escaping ([UserInfo]?, Error?) -> Void) -> URLSessionDataTask {
    let url = URL(string: "users?q=\(query)&page=\(page)", relativeTo: baseURL)!
    return session.dataTask(with: url) { _, _, _ in
      
    }
  }
}
