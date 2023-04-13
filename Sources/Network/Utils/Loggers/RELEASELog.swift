//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 13.04.2023.
//

import Foundation
import Alamofire
import NetworkInterface

public struct RELEASELog: Loger {
    public func log<T>(_ response: Alamofire.AFDataResponse<T?>, _ config: NetworkInterface.Requestable?) {}
    
    public func log<T, E>(_ response: Alamofire.DataResponse<T, E>, _ config: NetworkInterface.Requestable?) where E : Error {}
    
    public func log(_ response: Alamofire.DownloadResponsePublisher<Data>.Output, _ config: NetworkInterface.Requestable?) {}
    
    public func success<T>(_ value: T) {}
    
    public func failure(_ error: Error) {}
}
