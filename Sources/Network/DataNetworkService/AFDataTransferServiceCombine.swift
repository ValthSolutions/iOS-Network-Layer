//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 01.03.2023.
//

import Foundation
import Alamofire
import Combine
import NetworkInterface

public protocol DataTransferServiceProtocol {
    func request<T: Decodable, E: ResponseRequestable>(with endpoint: E)
    -> AnyPublisher<T, DataTransferError> where E.Response == T
    
    func request<E: ResponseRequestable>(with endpoint: E)
    -> AnyPublisher<Data, DataTransferError> where E.Response == Data
}



public final class AFDataTransferServiceCombine {
    
    private let networkService: AFNetworkServiceCombine
    private let logger: Log
    
    public init(with networkService: AFNetworkServiceCombine,
                logger: Log = DEBUGLog()) {
        self.networkService = networkService
        self.logger = logger
    }
    
    private func decode<T: Decodable>(data: Data, decoder: ResponseDecoder) throws -> T {
        do {
            let result: T = try decoder.decode(data)
            return result
        } catch {
            throw DataTransferError.parsing(error)
        }
    }
    
    public func request<T, E>(_ endpoint: E) -> AnyPublisher<T, DataTransferError> where T: Decodable, T == E.Response, E: ResponseRequestable {
        
        return networkService.request(endpoint: endpoint)
            .tryMap { data -> T in
                let result: T = try self.decode(data: data, decoder: endpoint.responseDecoder)
                return result
            }
            .mapError { error -> DataTransferError in
//                self.logger.log(error: error)
                return DataTransferError.noResponse
            }
            .eraseToAnyPublisher()
    }
//    
//    public func download(_ url: URL) -> AnyPublisher<Data, Error> {
//        return networkService.download(url)
//            .eraseToAnyPublisher()
//    }
//    
//    public func upload<T: Decodable>(_ data: Data, to url: URL, decoder: ResponseDecoder) -> AnyPublisher<T, Error> {
//        return networkService.upload(data, to: url)
//            .tryMap { [weak self] data -> T in
//                guard let self = self else { throw DataTransferError.noResponse }
//                return try self.decode(data: data, decoder: decoder)
//            }
//            .eraseToAnyPublisher()
//    }
//    
//    public func upload<T: Decodable>(multipartFormData: @escaping (MultipartFormData) -> Void, to url: URL, decoder: ResponseDecoder) -> AnyPublisher<T, Error> {
//        return networkService.upload(multipartFormData: multipartFormData, to: url)
//            .tryMap { [weak self] data -> T in
//                guard let self = self else { throw DataTransferError.noResponse }
//                return try self.decode(data: data, decoder: decoder)
//            }
//            .eraseToAnyPublisher()
//    }
}
