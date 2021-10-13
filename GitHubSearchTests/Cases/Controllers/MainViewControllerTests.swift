//
//  MainViewControllerTests.swift
//  GitHubSearchTests
//
//  Created by David on 2021/10/14.
//

@testable import GitHubSearch
import XCTest

class MainViewControllerTests: XCTestCase {
  // MARK: - Instance Properties - Tests
  var sut: MainViewController!
  
  override func setUp() {
    super.setUp()
    sut = MainViewController()
    sut.loadViewIfNeeded()
  }
  
  override func tearDown() {
    sut = nil
    super.tearDown()
  }
  
  func test_networkClient_setToGitHubSearchClient() {
    XCTAssertTrue((sut.networkClient as? GitHubSearchClient) === GitHubSearchClient.shared)
  }
  
  func test_loadUserData_setsRequest() {
    // given
    let mockNetworkClient = MockGitHubSearchService()
    sut.networkClient = mockNetworkClient
  }
  
  func test_loadUserData_ifAlreadyLoaded_doesntCallAgain() {
    // given
    let mockNetworkClient = MockGitHubSearchService()
    sut.networkClient = mockNetworkClient
    
    // when
    sut.loadUserData()
    sut.loadUserData()
    
    // then
    XCTAssertEqual(mockNetworkClient.getSearchResultCallCount, 1)
  }
}
