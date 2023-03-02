//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 01.03.2023.
//


import Foundation
import Alamofire
import Combine

public protocol AFNetworkServiceProtocol {
    func request(endpoint: Requestable) -> AnyPublisher<Data, Error>
    func download(endpoint: Requestable) -> AnyPublisher<Data, Error>
    func upload(_ data: Data, to url: URL) -> AnyPublisher<Progress, Error>
    func upload(multipartFormData: @escaping (MultipartFormData) -> Void,
                to url: URL) -> AnyPublisher<Progress, Error>
}

