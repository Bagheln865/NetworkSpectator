//
//  Mock.swift
//  NetworkSpectator
//
//  Created by Pankaj Bawane on 15/12/25.
//

import Foundation

public enum MimeType: Equatable, Codable, Hashable, Sendable {
    case json
    case xml
    case html
    case plainText
    case imageJpeg
    case imagePng
    case empty
    case custom(String)
    
    var raw: String {
        switch self {
        case .json: return "application/json"
        case .xml: return "application/xml"
        case .html: return "text/html"
        case .plainText: return "text/plain"
        case .imageJpeg: return "image/jpeg"
        case .imagePng: return "image/png"
        case .empty: return ""
        case .custom(let value): return value
        }
    }
}

public struct HTTPResponse: Sendable {
    let headers: [String: String]
    let statusCode: Int
    let responseData: Data?
    let error: Error?
    let responseTime: Double
    let mimeType: MimeType
    
    public init(headers: [String : String],
                statusCode: Int, responseData: Data?,
                error: Error?,
                responseTime: Double = 0,
                mimeType: MimeType = .empty,
                textEncoding: String? = nil) {
        self.headers = headers
        self.statusCode = statusCode
        self.responseData = responseData
        self.error = error
        self.responseTime = responseTime
        self.mimeType = mimeType
    }
    
    internal func urlResponse(_ request: URLRequest) -> HTTPURLResponse? {
        guard let url = request.url else { return nil }
        
        var httpHeaders = headers
        if mimeType != .empty {
            httpHeaders["Content-Type"] = mimeType.raw
        }
        let response = HTTPURLResponse(url: url,
                                       statusCode: statusCode,
                                       httpVersion: nil,
                                       headerFields: httpHeaders)
        return response
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        headers = try container.decode([String: String].self, forKey: .headers)
        statusCode = try container.decode(Int.self, forKey: .statusCode)
        responseData = try container.decodeIfPresent(Data.self, forKey: .responseData)
        responseTime = try container.decode(Double.self, forKey: .responseTime)
        mimeType = try container.decode(MimeType.self, forKey: .mimeType)
        self.error = nil
    }
}

extension HTTPResponse: Equatable {
    public static func == (lhs: HTTPResponse, rhs: HTTPResponse) -> Bool {
        lhs.mimeType == rhs.mimeType &&
        lhs.headers == rhs.headers &&
        lhs.statusCode == rhs.statusCode &&
        lhs.responseData == rhs.responseData &&
        lhs.responseTime == rhs.responseTime
    }
}

extension HTTPResponse: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(mimeType)
        hasher.combine(headers)
        hasher.combine(statusCode)
        hasher.combine(responseData)
        hasher.combine(responseTime)
    }
}

extension HTTPResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case headers, statusCode, responseData, responseTime, mimeType, textEncoding
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(headers, forKey: .headers)
        try container.encode(statusCode, forKey: .statusCode)
        try container.encode(responseData, forKey: .responseData)
        try container.encode(responseTime, forKey: .responseTime)
        try container.encode(mimeType, forKey: .mimeType)
    }
}

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
