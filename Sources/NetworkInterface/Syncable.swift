//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 28.02.2023.
//

import Combine
import Foundation


public protocol Syncable {
    
    associatedtype Remote: RemoteStore
    
    var remote: Remote { get }
}

public protocol RemoteStore {
    
    func send(request: RequestProvider, responseString: @escaping (Result<String, Error>) -> Void)
    func send(request: RequestProvider, responseData: @escaping (Result<Data, Error>) -> Void)
    func send(request: RequestProvider, responseJSON: @escaping (Result<Any, Error>) -> Void)
    func send<Item>(request: RequestProvider, keyPath: String?, responseItem: @escaping (Result<Item, Error>) -> Void)
}

public protocol RemoteStoreObjects: RemoteStore {
    associatedtype Item
    
    func send(request: RequestProvider, keyPath: String?, responseObject: @escaping (Result<Item, Error>) -> Void)
    func send(request: RequestProvider, keyPath: String?, responseArray: @escaping (Result<[Item], Error>) -> Void)
}
    
//MARK: - Reactive
public protocol RSyncable {
    
    associatedtype Remote: RRemoteStore
    
    var remote: Remote { get }
}

public protocol RRemoteStore {
    associatedtype StringPublisher: Publisher where StringPublisher.Output == String, StringPublisher.Failure == Error
    associatedtype DataPublisher: Publisher where DataPublisher.Output == Data, DataPublisher.Failure == Error
    associatedtype JSONPublisher: Publisher where JSONPublisher.Output == Any, JSONPublisher.Failure == Error
    associatedtype ItemPublisher: Publisher where ItemPublisher.Failure == Error
    
    associatedtype Item: Decodable
    
    func send(request: RequestProvider) -> StringPublisher
    func send(request: RequestProvider) -> DataPublisher
    func send(request: RequestProvider) -> JSONPublisher
    func send(request: RequestProvider, decodingType: Item.Type, keyPath: String?) -> ItemPublisher
}
