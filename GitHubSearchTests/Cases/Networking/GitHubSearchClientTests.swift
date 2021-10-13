//
//  GitHubSearchClientTests.swift
//  GitHubSearchTests
//
//  Created by David on 2021/10/13.
//

@testable import GitHubSearch
import XCTest

class GitHubSearchClientTests: XCTestCase {
  var sut: GitHubSearchClient!
  
  func test_init_sets_baseURL() {
    // given
    let baseURL = URL(string: "https://api.github.com/search/")!
    
    // when
    sut = GitHubSearchClient(baseURL: baseURL)
    
    // then
    XCTAssertEqual(sut.baseURL, baseURL)
  }
}
