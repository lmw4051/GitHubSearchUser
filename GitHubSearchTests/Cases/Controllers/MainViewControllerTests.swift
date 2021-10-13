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
  var mockNetworkClient: MockGitHubSearchService!
  
  // MARK: - Test Lifecycle
  override func setUp() {
    super.setUp()
    sut = MainViewController()
    sut.loadViewIfNeeded()
  }
  
  override func tearDown() {
    mockNetworkClient = nil
    sut = nil
    super.tearDown()
  }
  
  // MARK: - Given
  func givenMockNetworkClient() {
    mockNetworkClient = MockGitHubSearchService()
    sut.networkClient = mockNetworkClient
  }
  
  func test_networkClient_setToGitHubSearchClient() {
    XCTAssertTrue((sut.networkClient as? GitHubSearchClient) === GitHubSearchClient.shared)
  }
  
  func test_loadUserData_setsRequest() {
    // given
    givenMockNetworkClient()
    
    // when
    sut.loadUserData()
    
    // then
    XCTAssertEqual(sut.dataTask, mockNetworkClient.getSearchResultDataTask)
  }
  
  func test_loadUserData_ifAlreadyLoaded_doesntCallAgain() {
    // given
    givenMockNetworkClient()
    
    // when
    sut.loadUserData()
    sut.loadUserData()
    
    // then
    XCTAssertEqual(mockNetworkClient.getSearchResultCallCount, 1)
  }
}
