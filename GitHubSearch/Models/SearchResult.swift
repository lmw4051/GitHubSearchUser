//
//  SearchResult.swift
//  GitHubSearch
//
//  Created by David on 2021/10/13.
//

import Foundation

struct SearchResult: Decodable {
  var items: [UserInfo]
}

struct UserInfo: Decodable {
  let login: String
  let score: Double
  let avatar_url: String
}
