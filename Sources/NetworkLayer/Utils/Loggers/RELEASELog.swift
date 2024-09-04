//
//  File.swift
//
//
//  Created by LEMIN DAHOVICH on 13.04.2023.
//

import Foundation
import Alamofire
import INetwork

public struct RELEASELog: Loger {
    
    public init() {}
        
    public func log<T>(_ response: Alamofire.AFDataResponse<T?>, _ config: Requestable?) {}
    public func log<T, E>(_ response: Alamofire.DataResponse<T, E>, _ config: Requestable?) where E : Error {}
    public func log(_ response: Alamofire.DownloadResponsePublisher<Data>.Output, _ config: Requestable?) {}
    public func success<T>(_ value: T) {}
    public func failure(_ error: Error) {}
    public func logStreamChunk(_ result: Result<Data, Never>) { }
    public func logStreamCompletion(_ completion: DataStreamRequest.Completion) { }
    public func logRequestInitiation(_ request: URLRequest?) { }

}
