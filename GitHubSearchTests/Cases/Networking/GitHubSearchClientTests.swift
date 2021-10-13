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
    sut = GitHubSearchClient(baseURL: baseURL,
                             session: mockSession,
                             responseQueue: nil)
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
    
    let mockTask = sut.getUsers(with: "a", page: 1) { searchResult, error in
      calledCompletion = true
      receivedUsers = searchResult?.items
      receivedError = error as NSError?
    } as! MockURLSessionDataTask
    
    mockTask.completionHandler(data, response, error)
    return (calledCompletion, receivedUsers, receivedError)
  }
  
  func verifyGetUsersDispatchedToMain(
    data: Data? = nil,
    statusCode: Int = 200,
    error: Error? = nil,
    line: UInt = #line) {
    
    mockSession.givenDispatchQueue()
    sut = GitHubSearchClient(baseURL: baseURL,
                             session: mockSession,
                             responseQueue: .main)
    
    let expectation = self.expectation(description: "Completion wasn't called")
    
    // when
    var thread: Thread!
    let mockTask = sut.getUsers(with: "a", page: 1) { users, error in
      thread = Thread.current
      expectation.fulfill()
    } as! MockURLSessionDataTask
    
    let response = HTTPURLResponse(url: getUsersURL,
                                   statusCode: statusCode,
                                   httpVersion: nil,
                                   headerFields: nil)
    mockTask.completionHandler(data, response, error)
    
    // then
    waitForExpectations(timeout: 0.2) { _ in
      XCTAssertTrue(thread.isMainThread, line: line)
    }
  }
  
  func test_conformsTo_GitHubSearchService() {
    XCTAssertTrue((sut as AnyObject) is GitHubSearchService)
  }
  
  func test_GitHubSearchService_declaresGetUsers() {
    // given
    let service = sut as GitHubSearchService
    
    // then
    _ = service.getUsers(with: "a", page: 1) { _, _ in }
  }    
  
  func test_shared_setsBaseURL() {
    // given
    let baseURL = URL(string: "https://api.github.com/search/")!
    
    // then
    XCTAssertEqual(GitHubSearchClient.shared.baseURL, baseURL)
  }
  
  func test_shared_setsSession() {
    // given
    let session = URLSession.shared
    
    // then
    XCTAssertEqual(GitHubSearchClient.shared.session, session)
  }
  
  func test_shared_setsResponseQueue() {
    // given
    let responseQueue = DispatchQueue.main
    
    // then
    XCTAssertEqual(GitHubSearchClient.shared.responseQueue, responseQueue)
  }
  
  func test_init_sets_baseURL() {
    XCTAssertEqual(sut.baseURL, baseURL)
  }
  
  func test_init_sets_session() {
    XCTAssertEqual(sut.session, mockSession)
  }
  
  func test_init_sets_responseQueue() {
    // given
    let responseQueue = DispatchQueue.main
    
    // when
    sut = GitHubSearchClient(baseURL: baseURL,
                             session: mockSession,
                             responseQueue: responseQueue)
    
    // then
    XCTAssertEqual(sut.responseQueue, responseQueue)
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
  
  func test_getUsers_givenHTTPStatusError_dispatchesToResponseQueue() {
    verifyGetUsersDispatchedToMain(statusCode: 500)
  }
  
  func test_getUsers_givenError_dispatchesToResponseQueue() {
    // given
    let error = NSError(domain: "com.GitHubSearchTests", code: 42)
    
    // then
    verifyGetUsersDispatchedToMain(error: error)
  }
  
  func test_getUsers_givenGoodResponse_dispatchesToResponseQueue() throws {
    // given
    let data = try Data.fromJSON(fileName: "GET_Users_ValidResponse")
    
    // then
    verifyGetUsersDispatchedToMain(data: data)
  }
  
  func test_getUsers_givenInvalidResponse_dispatchesToResponseQueue() throws {
    // given
    let data = try Data.fromJSON(fileName: "GET_MissingValues_Response")
    
    // then
    verifyGetUsersDispatchedToMain(data: data)
  }
}

class MockURLSession: URLSession {
  var queue: DispatchQueue? = nil
  
  func givenDispatchQueue() {
    queue = DispatchQueue(label: "com.GitHubSearchTests.MockSession")
  }
  
  override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
    return MockURLSessionDataTask(completionHandler: completionHandler,
                                  url: url,
                                  queue: queue)
  }
}

class MockURLSessionDataTask: URLSessionDataTask {
  var completionHandler: (Data?, URLResponse?, Error?) -> Void
  var url: URL
  
  init(completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void,
       url: URL,
       queue: DispatchQueue?) {
    
    if let queue = queue {
      self.completionHandler = { data, response, error in
        queue.async {
          completionHandler(data, response, error)
        }
      }
    } else {
      self.completionHandler = completionHandler
    }
    
    self.url = url
    super.init()
  }
  
  var calledResume = false
  override func resume() {
    calledResume = true
  }
}
