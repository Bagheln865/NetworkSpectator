//
//  Mock.swift
//  NetworkSpectator
//
//  Created by Pankaj Bawane on 15/12/25.
//

import Foundation

/// Represents a mock HTTP response for network request interception.
public struct Mock: Identifiable, Sendable {
    public let id: UUID
    public let rule: MatchRule
    public let response: HTTPResponse
    let saveLocally: Bool

    /// Creates a mock with rule-based matching and JSON response.
    /// - Parameters:
    ///   - rule: Rule to match against the request URL.
    ///   - response: JSON object to be serialized as the response body.
    ///   - headers: HTTP headers to include in the response.
    ///   - statusCode: HTTP status code for the response.
    ///   - error: Optional error to return instead of a successful response.
    ///   - saveLocally: Store mock on device.
    ///   - delay: delay in response.
    internal init(rule: MatchRule,
                  response: Data?,
                  headers: [String: String],
                  statusCode: Int,
                  error: Error?,
                  saveLocally: Bool,
                  delay: Double = 0) {
        let httpResponse = HTTPResponse(headers: headers,
                                    statusCode: statusCode,
                                    responseData: response,
                                    error: error,
                                    responseTime: delay)
        self.init(rule: rule, response: httpResponse, saveLocally: saveLocally)
    }
    
    internal init(rule: MatchRule,
                  response: HTTPResponse,
                  saveLocally: Bool) {
        self.id = UUID()
        self.rule = rule
        self.response = response
        self.saveLocally = saveLocally
    }
    
    public init(rule: MatchRule,
                response: HTTPResponse) {
        self.init(rule: rule, response: response, saveLocally: false)
    }
    
    public init(rule: MatchRule,
                response: Data?,
                headers: [String: String] = [:],
                statusCode: Int = 200,
                error: Error? = nil,
                delay: Double = 0) {
        let httpResponse = HTTPResponse(headers: headers,
                                        statusCode: statusCode,
                                        responseData: response,
                                        error: error,
                                        responseTime: delay)
        self.init(rule: rule, response: httpResponse, saveLocally: false)
    }
    
    public init(rule: MatchRule,
                response: [AnyHashable: Any],
                headers: [String: String] = [:],
                statusCode: Int = 200,
                error: Error? = nil,
                delay: Double = 0) throws {
        let respnseData = try JSONSerialization.data(withJSONObject: response)
        let response = HTTPResponse(headers: headers,
                                    statusCode: statusCode,
                                    responseData: respnseData,
                                    error: error,
                                    responseTime: delay)
        self.init(rule: rule, response: response, saveLocally: false)
    }
}

extension Mock: Equatable {
    public static func == (lhs: Mock, rhs: Mock) -> Bool {
        lhs.rule == rhs.rule &&
        lhs.response == rhs.response
    }
}

extension Mock: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rule)
        hasher.combine(response)
    }
}

extension Mock: Codable {
}
