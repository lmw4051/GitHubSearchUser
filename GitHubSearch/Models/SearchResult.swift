//
//  SearchResult.swift
//  GitHubSearch
//
//  Created by David on 2021/10/13.
//

import Foundation

struct SearchResult: Decodable {
  var items: [User]
}

struct User: Decodable, Equatable {
  let login: String
  let score: Double
  let avatar_url: String
}
