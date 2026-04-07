//
//  TestServer.swift
//  NetworkSpectator
//
//  Created by Pankaj Bawane on 29/03/26.
//

import Foundation

/// Entry point for using NetworkSpectator in unit tests.
///
/// Call ``setUp()`` at the start of your test (or in a shared setup method)
/// and ``tearDown()`` when done.  Between those calls, register mocks with
/// the convenience `mock(…)` methods.
///
/// ```swift
/// // One time setup in Tests.
/// NetworkSpectator.test.setUp()
///
/// // Register a mock response.
/// NetworkSpectator.test.setResponse(
///     rule: .path("/api/users"),
///     json: ["name": "pankaj"],
///     statusCode: 200
/// )
///
/// // … run your networking code …
///
/// ```

public class TestServer: @unchecked Sendable {
    
    // MARK: - Lifecycle
    
    internal init() {}
    
    private(set) var isLoggingEnabled: Bool = false
    private var setupComplete: Bool = false
    
    /// Enables network interception with the test logger.
    /// Call once before your tests make network requests.
    func setUp(logging: Bool = false) {
        guard !setupComplete else { return }
        defer { setupComplete = true }
        isLoggingEnabled = logging
        NetworkURLProtocol.logger = TestItemLogger()
        NetworkURLProtocol.mockServer = .testServer
        NetworkURLProtocol.mockServer.clear()
        NetworkInterceptor.shared.enable()
    }
    
    /// Disables interception and removes all mocks.
    /// Call after your tests complete.
     func tearDown() {
        guard setupComplete else { return }
        defer { setupComplete = false }
        isLoggingEnabled = false
        NetworkInterceptor.shared.disable()
        NetworkURLProtocol.mockServer.clear()
        NetworkURLProtocol.mockServer = .shared
    }
    
    // MARK: - Mock Registration
    
    /// Mocks a JSON response for requests matching the given rule.
    ///
    /// - Parameters:
    ///   - rule: The ``MatchRule`` that determines which requests are intercepted.
    ///   - json: A JSON-serializable dictionary returned as the response body.
    ///   - statusCode: HTTP status code (default `200`).
    ///   - headers: Additional response headers (default empty).
    ///   - delay: Simulated network delay in seconds (default `0`).
    func setResponse(
        method: HTTPMethod,
        rule: MatchRule,
        json: [String: Any],
        statusCode: Int = 200,
        headers: [String: String] = [:],
        delay: Double = 0
    ) {
        let data = try? JSONSerialization.data(withJSONObject: json)
        let response = HTTPResponse(
            headers: headers,
            statusCode: statusCode,
            responseData: data,
            error: nil,
            responseTime: delay,
            mimeType: .json
        )
        NetworkURLProtocol.mockServer.register(Mock(method: method, rule: rule, response: response))
    }
    
    /// Mocks a raw `Data` response for requests matching the given rule.
    ///
    /// - Parameters:
    ///   - rule: The ``MatchRule`` that determines which requests are intercepted.
    ///   - data: Raw bytes returned as the response body.
    ///   - statusCode: HTTP status code (default `200`).
    ///   - headers: Additional response headers (default empty).
    ///   - delay: Simulated network delay in seconds (default `0`).
    func setResponse(
        method: HTTPMethod,
        rule: MatchRule,
        data: Data?,
        statusCode: Int = 200,
        headers: [String: String] = [:],
        delay: Double = 0
    ) {
        let response = HTTPResponse(
            headers: headers,
            statusCode: statusCode,
            responseData: data,
            error: nil,
            responseTime: delay
        )
        NetworkURLProtocol.mockServer.register(Mock(method: method, rule: rule, response: response))
    }
    
    /// Mocks a network failure for requests matching the given rule.
    ///
    /// - Parameters:
    ///   - rule: The ``MatchRule`` that determines which requests are intercepted.
    ///   - error: The error to surface (default `URLError(.notConnectedToInternet)`).
    func setErrorResponse(
        method: HTTPMethod,
        rule: MatchRule,
        error: Error = URLError(.notConnectedToInternet)
    ) {
        let response = HTTPResponse(
            headers: [:],
            statusCode: 0,
            responseData: nil,
            error: error
        )
        NetworkURLProtocol.mockServer.register(Mock(method: method, rule: rule, response: response))
    }
    
    // MARK: - Mock Removal
    
    /// Removes all registered mocks.
    func removeAllMocks() {
        NetworkURLProtocol.mockServer.clear()
    }
}
