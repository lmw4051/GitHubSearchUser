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
  
  func whenGetUsers(data: Data? = nil,
                    statusCode: Int = 200,
                    error: Error? = nil) -> (calledCompletion: Bool, users: [User]?, error: Error?) {
    let response = HTTPURLResponse(url: getUsersURL,
                                   statusCode: statusCode,
                                   httpVersion: nil,
                                   headerFields: nil)
    
    // when
    var calledCompletion = false
    var receivedUsers: [User]? = nil
    var receivedError: Error? = nil
    
    let mockTask = sut.getUsers(with: "a", page: 1) { users, error in
      calledCompletion = true
      receivedUsers = users
      receivedError = error as NSError?
    } as! MockURLSessionDataTask
    
    mockTask.completionHandler(data, response, error)
    return (calledCompletion, receivedUsers, receivedError)
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
    // when
    let result = whenGetUsers(statusCode: 500)
    
    // then
    XCTAssertTrue(result.calledCompletion)
    XCTAssertNil(result.users)
    XCTAssertNil(result.error)
  }
  
  func test_getUsers_givenError_callsCompletionWithError() throws {
    // given
    let expectedError = NSError(domain: "com.GitHubSearchClient",
                                code: 42)
    
    // when
    let result = whenGetUsers(error: expectedError)
    
    // then
    XCTAssertTrue(result.calledCompletion)
    XCTAssertNil(result.users)
    
    let actualError = try XCTUnwrap(result.error as NSError?)
    XCTAssertEqual(actualError, expectedError)
  }
  
  func test_getUsers_givenValidJSON_callsCompletionWithUsers() throws {
    // given
    let data = try Data.fromJSON(fileName: "GET_Users_ValidResponse")
    let decoder = JSONDecoder()
    let searchResult = try decoder.decode(SearchResult.self, from: data)
    
    // when
    let result = whenGetUsers(data: data)
    
    // then
    XCTAssertTrue(result.calledCompletion)
    XCTAssertEqual(result.users, searchResult.items)
    XCTAssertNil(result.error)
  }
  
  func test_getUsers_givenInvalidJSON_callsCompletionWithError() throws {
    // given
    let data = try Data.fromJSON(fileName: "GET_MissingValues_Response")
    var expectedError: NSError!
    let decoder = JSONDecoder()
    
    do {
      _ = try decoder.decode(SearchResult.self, from: data)
    } catch {
      expectedError = error as NSError
    }
    
    // when
    let result = whenGetUsers(data: data)
    
    // then
    XCTAssertTrue(result.calledCompletion)
    XCTAssertNil(result.users)
    
    let actualError = try XCTUnwrap(result.error as NSError?)
    XCTAssertEqual(actualError.domain, expectedError.domain)
    XCTAssertEqual(actualError.code, expectedError.code)
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
