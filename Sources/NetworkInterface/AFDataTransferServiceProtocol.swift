//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 01.03.2023.
//

import Foundation
import Combine
import Alamofire

public protocol AFDataTransferServiceCombineProtocol {
    func download<T, E>(_ endpoint: E) -> AnyPublisher<T, DataTransferError> where T: Decodable, T == E.Response, E: ResponseRequestable
    func request<T, E>(_ endpoint: E) -> AnyPublisher<T, DataTransferError> where T: Decodable, T == E.Response, E: ResponseRequestable
    func upload<T, E>(_ value: Data, _ endpoint: E) -> (AnyPublisher<Progress, DataTransferError>, AnyPublisher<T, DataTransferError>) where T: Decodable, T == E.Response, E: ResponseRequestable
    func upload<T, E>(_ endpoint: E,
                           multipartFormData: @escaping (MultipartFormData) -> Void)
    -> (AnyPublisher<Progress, DataTransferError>, AnyPublisher<T, DataTransferError>)
    where T: Decodable, T == E.Response, E: ResponseRequestable
}

public protocol AFDataTransferServiceProtocol {
    func request<T, E>(_ endpoint: E) async throws -> T where T: Decodable, T == E.Response, E: ResponseRequestable
    func download<T: Decodable, E: ResponseRequestable>(_ endpoint: E) async throws -> T
    func upload(_ value: String, url: URL) async throws -> Progress
    func upload(multipartFormData: @escaping (MultipartFormData) -> Void,
                to url: URL) async throws -> Progress
}

public enum DataTransferError: Error {
    case noResponse
    case parsing(Error)
    case networkFailure(NetworkError)
    case networkAdaptableError(Error)
    case resolvedNetworkFailure(Error)
}

public enum NetworkError: Error {
    case error(statusCode: Int, data: Data)
    case unacceptableStatusCode(statusCode: Int)
    case notConnectedToInternet
    case cancelled
    case generic(Error)
    case urlGeneration
    case unknown
    case noData
}

public enum AdapterError: Error {
    case defaultError
    case generic(String)
    case decoding(String)
    case notConnectedToInternet(String)
    case serverErrors(String, Int?)
}

public enum NetworkStatusCode: Int {
    case success = 200
    case created = 201
    case accepted = 202
    case noContent = 204
    case resetContent = 205
    case partialContent = 206
    case multiStatus = 207
    case alreadyReported = 208
    case imUsed = 226
    case genericErrorCode = 400

    public var isAcceptable: Bool {
        return (200...299).contains(rawValue)
    }
}

extension NetworkError {
    public var isNotFoundError: Bool {
        return hasStatusCode(404)
    }
    
    public func hasStatusCode(_ codeError: Int) -> Bool {
        switch self {
        case let .error(code, _):
            return code == codeError
        default: return false
        }
    }
}

public struct Voidable: Decodable {}
