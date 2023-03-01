//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 01.03.2023.
//

import Foundation
import NetworkInterface
import Combine


public class NetworkSessionManager: NetworkSessionManagerProtocol {

  public init() {}

  public func request(_ request: URLRequest) -> AnyPublisher<NetworkingOutput, URLError> {
    return URLSession.shared.dataTaskPublisher(for: request).eraseToAnyPublisher()
  }
}
