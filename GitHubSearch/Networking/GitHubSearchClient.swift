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
        
        guard let responseQueue = self.responseQueue else {
          completion(nil, error)
          return
        }
        responseQueue.async {
          completion(nil, error)
        }
        return
      }
      
      let decoder = JSONDecoder()
      
      do {
        let searchResult = try decoder.decode(SearchResult.self, from: data)
        completion(searchResult.items, nil)
      } catch {
        completion(nil, error)
      }
    }
    task.resume()
    return task
  }
}
