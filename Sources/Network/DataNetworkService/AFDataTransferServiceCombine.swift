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
            print(error)
            throw DataTransferError.parsing(error)
        }
    }
    
    public func encode<E: Encodable>(_ value: E, encoder: DataEncoder) throws -> Data {
        return try encoder.encode(value)
    }
    
    public func request<T, E>(_ endpoint: E) -> AnyPublisher<T, DataTransferError> where T: Decodable, T == E.Response, E: ResponseRequestable {
        return networkService.request(endpoint: endpoint)
            .tryMap { data -> T in
                let result: T = try self.decode(data: data, decoder: endpoint.responseDecoder)
                return result
            }
            .mapError { error -> DataTransferError in
                print(error)
                return DataTransferError.noResponse
            }
            .eraseToAnyPublisher()
    }
    
    public func download<T, E>(_ endpoint: E) -> AnyPublisher<T, DataTransferError> where T: Decodable, T == E.Response, E: ResponseRequestable {
        return networkService.download(endpoint: endpoint)
            .tryMap { data -> T in
                let result: T = try self.decode(data: data, decoder: endpoint.responseDecoder)
                return result
            }
            .mapError { error -> DataTransferError in
                print(error)
                return DataTransferError.noResponse
            }
            .eraseToAnyPublisher()
    }
    
    public func upload(_ value: String, url: URL) -> AnyPublisher<Progress, Error> {
        let encodedData = try! self.encode(value, encoder: JSONEncoderData())
        return networkService.upload(encodedData, to: url)
    }
    
    public func upload(multipartFormData: @escaping (MultipartFormData) -> Void, to url: URL) -> AnyPublisher<Progress, Error> {
        return networkService.upload(multipartFormData: multipartFormData, to: url)
    }

}
