//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 01.03.2023.
//

import Foundation
import NetworkInterface
import Combine

extension AFNetworkService: RemoteStorePublisher {
    public typealias StringPublisher = AnyPublisher<String, Error>
    public typealias DataPublisher = AnyPublisher<Data, Error>
    public typealias JSONPublisher = AnyPublisher<Any, Error>
    public typealias ItemPublisher<Item> = AnyPublisher<Item, Error>
    
    public func send(request: RequestProvider) -> StringPublisher {
        return Future<String, Error> { promise in
            self.send(request: request) { result in
                switch result {
                case .success(let string):
                    promise(.success(string))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    public func send(request: RequestProvider) -> DataPublisher {
        return Future<Data, Error> { promise in
            self.send(request: request) { result in
                switch result {
                case .success(let data):
                    promise(.success(data))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    public func send(request: RequestProvider) -> JSONPublisher {
        return Future<Any, Error> { promise in
            self.send(request: request) { result in
                switch result {
                case .success(let json):
                    promise(.success(json))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    public func send<Item>(request: RequestProvider, keyPath: String?) -> ItemPublisher<Item> {
        return Future<Item, Error> { promise in
            self.send(request: request, keyPath: keyPath) { result in
                switch result {
                case .success(let item):
                    promise(.success(item))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}
