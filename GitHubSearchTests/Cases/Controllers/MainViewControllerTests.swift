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
  func givenUsers(count: Int = 3) -> [User] {
    return (1 ... count).map { i in
      let user = User(login: "login_\(i)",
                      score: Double(i),
                      avatar_url: "http://example.com/\(i)")
      return user
    }
  }
  
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
    XCTAssertEqual(sut.dataTask, mockNetworkClient.getUserDataTask)
  }
  
  func test_loadUserData_ifAlreadyLoaded_doesntCallAgain() {
    // given
    givenMockNetworkClient()
    
    // when
    sut.loadUserData()
    sut.loadUserData()
    
    // then
    XCTAssertEqual(mockNetworkClient.getUserCallCount, 1)
  }
  
  func test_loadUserData_completionNilsDataTask() {
    // given
    givenMockNetworkClient()
    let users = givenUsers()
    
    // when
    sut.loadUserData()
    
    mockNetworkClient.getUserCompletion(users, nil)
    
    // then
    XCTAssertNil(sut.dataTask)
  }
}
