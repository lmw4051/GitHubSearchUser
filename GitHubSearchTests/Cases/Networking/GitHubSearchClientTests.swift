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
  var mockSession: MockURLSession!
  var sut: GitHubSearchClient!
  
  var getUsersURL: URL {
    return URL(string: "users?q=a&page=1", relativeTo: baseURL)!
  }
  
  override func setUp() {
    super.setUp()
    baseURL = URL(string: "https://api.github.com/search/")!
    mockSession = MockURLSession()
    sut = GitHubSearchClient(baseURL: baseURL, session: mockSession)
  }
  
  override func tearDown() {
    baseURL = nil
    mockSession = nil
    sut = nil
    super.tearDown()
  }
  
  func test_init_sets_baseURL() {
    XCTAssertEqual(sut.baseURL, baseURL)
  }
  
  func test_init_sets_session() {
    sut = GitHubSearchClient(baseURL: baseURL, session: mockSession)
    XCTAssertEqual(sut.session, mockSession)
  }
  
  func test_getUsers_callsExpectedURL() {
    // when
    let mockTask = sut.getUsers(with: "a", page: 1) { _, _ in } as! MockURLSessionDataTask
    
    // then
    XCTAssertEqual(mockTask.url, getUsersURL)
  }
  
  func test_getDogs_callsResumeOnTask() {
    // when
    let mockTask = sut.getUsers(with: "a", page: 1) { _, _ in } as! MockURLSessionDataTask
    
    // then
    XCTAssertTrue(mockTask.calledResume)
  }
  
  func test_getUsers_givenResponseStatusCode500_callsCompletion() {
    // given
    let response = HTTPURLResponse(url: getUsersURL,
                                   statusCode: 500,
                                   httpVersion: nil,
                                   headerFields: nil)
    
    // when
    var calledCompletion = false
    var receivedUsers: [User]? = nil
    var receivedError: Error? = nil
    
    let mockTask = sut.getUsers(with: "a", page: 1) { users, error in
      calledCompletion = true
      receivedUsers = users
      receivedError = error
    } as! MockURLSessionDataTask
    
    mockTask.completionHandler(nil, response, nil)
    
    // then
    XCTAssertTrue(calledCompletion)
    XCTAssertNil(receivedUsers)
    XCTAssertNil(receivedError)
  }
}

class MockURLSession: URLSession {
  override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
    return MockURLSessionDataTask(completionHandler: completionHandler,
                                  url: url)
  }
}

class MockURLSessionDataTask: URLSessionDataTask {
  var completionHandler: (Data?, URLResponse?, Error?) -> Void
  var url: URL
  
  init(completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void,
       url: URL) {
    self.completionHandler = completionHandler
    self.url = url
    super.init()
  }
  
  var calledResume = false
  override func resume() {
    calledResume = true
  }
}
