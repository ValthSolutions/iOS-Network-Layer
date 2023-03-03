//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 03.03.2023.
//
import Alamofire
import Foundation

public protocol Log {
    func log<T>(_ response: AFDataResponse<T?>)
    func log<T, E>(_ response: DataResponse<T, E>)
    func success<T>(_ value: T)
    func failure(_ error: Error)
    func log(_ response:  DownloadResponsePublisher<Data>.Output)
}
