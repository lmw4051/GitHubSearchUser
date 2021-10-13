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
  let responseQueue: DispatchQueue?
  
  init(baseURL: URL,
       session: URLSession,
       responseQueue: DispatchQueue?) {
    self.baseURL = baseURL
    self.session = session
    self.responseQueue = responseQueue
  }
  
  func getUsers(with query: String,
                page: Int,
                completion: @escaping ([User]?, Error?) -> Void) -> URLSessionDataTask {
    let url = URL(string: "users?q=\(query)&page=\(page)", relativeTo: baseURL)!
    
    let task = session.dataTask(with: url) { [weak self] data, response, error in
      guard let self = self else { return }
      guard let response = response as? HTTPURLResponse,
            response.statusCode == 200,
            error == nil,
            let data = data else {
        self.dispatchResult(error: error, completion: completion)
        return
      }
      
      let decoder = JSONDecoder()
      
      do {
        let searchResult = try decoder.decode(SearchResult.self, from: data)
        self.dispatchResult(models: searchResult.items, completion: completion)        
      } catch {
        self.dispatchResult(error: error, completion: completion)
      }
    }
    task.resume()
    return task
  }
  
  private func dispatchResult<T>(
    models: T? = nil,
    error: Error? = nil,
    completion: @escaping (T?, Error?) -> Void) {
    
    guard let responseQueue = self.responseQueue else {
      completion(models, error)
      return
    }
    responseQueue.async {
      completion(models, error)
    }
  }
}
