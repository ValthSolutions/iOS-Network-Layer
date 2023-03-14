//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 01.03.2023.
//

import Foundation
import Alamofire

public protocol Requestable {
    var path: String { get }
    var isFullPath: Bool { get }
    var method: HTTPMethodType { get }
    var headerParameters: [String: String] { get }
    var queryParametersEncodable: Encodable? { get }
    var queryParameters: [String: Any] { get }
    var bodyParametersEncodable: Encodable? { get }
    var bodyParameters: [String: Any] { get }
    var bodyEncoding: BodyEncoding { get }
}

public enum HTTPMethodType: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

public enum BodyEncoding {
    case jsonSerializationData
    case stringEncodingAscii
}

public protocol ResponseRequestable: Requestable {
    associatedtype Response
    
    var responseDecoder: ResponseDecoder { get }
}

public protocol ResponseDecoder {
    func decode<T: Decodable>(_ data: Data) throws -> T
}

public enum RequestGenerationError: Error {
    case components
}

public protocol DataEncoder {
    func encode<T: Encodable>(_ data: T) throws -> Data
}
