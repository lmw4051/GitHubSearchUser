//
//  GitHubSearchClientTests.swift
//  GitHubSearchTests
//
//  Created by David on 2021/10/13.
//

@testable import GitHubSearch
import XCTest

class GitHubSearchClientTests: XCTestCase {
  var baseURL: URL!
  var session: URLSession!
  var sut: GitHubSearchClient!
  
  override func setUp() {
    super.setUp()
    baseURL = URL(string: "https://api.github.com/search/")!
    session = URLSession.shared
    sut = GitHubSearchClient(baseURL: baseURL, session: session)
  }
  
  override func tearDown() {
    baseURL = nil
    session = nil
    sut = nil
    super.tearDown()
  }
  
  func test_init_sets_baseURL() {
    XCTAssertEqual(sut.baseURL, baseURL)
  }
  
  func test_init_sets_session() {    
    sut = GitHubSearchClient(baseURL: baseURL, session: session)
    XCTAssertEqual(sut.session, session)
  }
}
