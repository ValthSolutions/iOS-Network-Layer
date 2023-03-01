//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 01.03.2023.
//

import Foundation
import Combine

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

public func printIfDebug(_ string: String) {
  #if DEBUG
  print(string)
  #endif
}
