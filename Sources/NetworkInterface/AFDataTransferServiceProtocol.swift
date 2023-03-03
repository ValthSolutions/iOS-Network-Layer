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
    func upload(_ value: String, url: URL) -> AnyPublisher<Progress, Error>
    func upload(multipartFormData: @escaping (MultipartFormData) -> Void, to url: URL) -> AnyPublisher<Progress, Error>
}

public protocol AFDataTransferServiceProtocol {
    func request<T: Decodable, E: ResponseRequestable>(_ endpoint: E) async throws -> T
    func download<T: Decodable, E: ResponseRequestable>(_ endpoint: E) async throws -> T
    func upload(_ value: String, url: URL) async throws -> Progress
    func upload(multipartFormData: @escaping (MultipartFormData) -> Void,
                       to url: URL) async throws -> Progress
}

public enum DataTransferError: Error {
  case noResponse
  case parsing(Error)
  case networkFailure(NetworkError)
  case resolvedNetworkFailure(Error)
}


public enum NetworkError: Error {
  case error(statusCode: Int, data: Data)
  case notConnected
  case cancelled
  case generic(Error)
  case urlGeneration
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
