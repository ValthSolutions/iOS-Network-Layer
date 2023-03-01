//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 01.03.2023.
//


import Foundation
import Combine

public protocol NetworkServiceProtocol {
  func request(endpoint: Requestable) -> AnyPublisher<Data, NetworkError>
}

public protocol NetworkSessionManagerProtocol {
  typealias NetworkingOutput = (data: Data, response: URLResponse)
  func request(_ request: URLRequest) -> AnyPublisher<NetworkingOutput, URLError>
}

