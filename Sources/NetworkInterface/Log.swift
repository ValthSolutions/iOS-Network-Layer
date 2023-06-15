//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 03.03.2023.
//

import Alamofire
import Foundation

public protocol Loger {
    func log<T>(_ response: AFDataResponse<T?>, _ config: Requestable?)
    func log<T, E>(_ response: DataResponse<T, E>, _ config: Requestable?)
    func log(_ response: DownloadResponsePublisher<Data>.Output, _ config: Requestable?)
    
    func success<T>(_ value: T)
    func failure(_ error: Error)
}
