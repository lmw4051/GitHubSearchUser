//
//  GitHubSearchClient.swift
//  GitHubSearch
//
//  Created by David on 2021/10/13.
//

import Foundation

protocol GitHubSearchService {
  func getUsers(with query: String,
                page: Int,
                completion: @escaping ([User]?, HTTPURLResponse?, CustomError?) -> Void) -> URLSessionDataTask
}

class GitHubSearchClient {
  let baseURL: URL
  let session: URLSession
  let responseQueue: DispatchQueue?
  
  static let shared = GitHubSearchClient(
    baseURL: URL(string: "https://api.github.com/search/")!,
    session: .shared,
    responseQueue: .main)
  
  init(baseURL: URL,
       session: URLSession,
       responseQueue: DispatchQueue?) {
    self.baseURL = baseURL
    self.session = session
    self.responseQueue = responseQueue
  }
  
  func getUsers(with query: String,
                page: Int,
                completion: @escaping ([User]?, HTTPURLResponse?, CustomError?) -> Void) -> URLSessionDataTask {
    guard let url = URL(string: "users?q=\(query)&page=\(page)", relativeTo: baseURL) else {
      return URLSessionDataTask()
    }
    
    let task = session.dataTask(with: url) { [weak self] data, response, error in
      guard let self = self else { return }
      
      guard error == nil else {
        self.dispatchResult(error: CustomError.httpResponseError, completion: completion)
        print("Client Error")
        return
      }
      
      guard let response = response as? HTTPURLResponse,
            (200...299).contains(response.statusCode) else {
        print("Server Error")
        self.dispatchResult(models: nil, response: nil, error: CustomError.httpServerError, completion: completion)
        return
      }
                  
      guard let data = data else {
        self.dispatchResult(error: CustomError.dataError, completion: completion)
        return
      }
      
      let decoder = JSONDecoder()
      
      do {
        let searchResult = try decoder.decode(SearchResult.self, from: data)
        self.dispatchResult(models: searchResult.items, response: response, completion: completion)
      } catch {
        self.dispatchResult(error: CustomError.jsonDecoingError, completion: completion)
      }
    }
    task.resume()
    return task
  }
  
  private func dispatchResult<T>(
    models: T? = nil,
    response: HTTPURLResponse? = nil,
    error: CustomError? = nil,
    completion: @escaping (T?, HTTPURLResponse?, CustomError?) -> Void) {
    
    guard let responseQueue = self.responseQueue else {
      completion(models, response, error)
      return
    }
    responseQueue.async {
      completion(models, response, error)
    }
  }
}

extension GitHubSearchClient: GitHubSearchService { }
