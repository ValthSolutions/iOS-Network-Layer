//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 28.02.2023.
//

import Combine
import Foundation

    
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
    
    func send(request: Requestable) -> StringPublisher
    func send(request: Requestable) -> DataPublisher
    func send(request: Requestable) -> JSONPublisher
    func send(request: Requestable, decodingType: Item.Type, keyPath: String?) -> ItemPublisher
}
