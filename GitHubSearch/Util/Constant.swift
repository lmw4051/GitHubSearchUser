//
//  Constant.swift
//  GitHubSearch
//
//  Created by David on 2021/10/14.
//

import Foundation

enum CommonSetting {
  static let startPageNumber = 1
}

enum CustomError: Error {
  case httpResponseError
  case jsonDecoingError
  case dataError
  case httpServerError
  case noResultFoundError
}
