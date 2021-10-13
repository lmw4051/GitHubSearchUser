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
}
