//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 01.03.2023.
//


import Foundation
import Alamofire
import Combine

public protocol AFNetworkServiceCombineProtocol: AnyObject {
    func request(endpoint: Requestable) -> AnyPublisher<Data, Error>
    func download(endpoint: Requestable) -> AnyPublisher<Data, Error>
    func upload(endpoint: Requestable, _ data: Data) -> AnyPublisher<(Progress, Data?), Error>
    func upload(endpoint: Requestable,
                     multipartFormData: @escaping (MultipartFormData) -> Void) -> AnyPublisher<(Progress, Data?), Error>
}

public protocol AFNetworkServiceProtocol: AnyObject {
    var encoder: JSONEncoder { get }
    func streamRequest(endpoint: Requestable) async throws -> DataStreamRequest
    func request(endpoint: Requestable) async throws -> Data
    func download(endpoint: Requestable) async throws -> Data
    func upload(_ data: Data, to url: URL) async throws -> Progress
    func upload(multipartFormData: @escaping (MultipartFormData) -> Void,
                to url: URL) async throws -> Data?
}
