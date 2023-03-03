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

public final class AFDataTransferServiceCombine: DataTransferService, AFDataTransferServiceCombineProtocol {
    
    private let networkService: AFNetworkServiceCombine
    
    public init(with networkService: AFNetworkServiceCombine) {
        self.networkService = networkService
    }
    
    public func request<T, E>(_ endpoint: E) -> AnyPublisher<T, DataTransferError>
    where T: Decodable, T == E.Response, E: ResponseRequestable {
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
    
    public func download<T, E>(_ endpoint: E) -> AnyPublisher<T, DataTransferError>
    where T: Decodable, T == E.Response, E: ResponseRequestable {
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
    
    public func upload(multipartFormData: @escaping (MultipartFormData) -> Void,
                       to url: URL) -> AnyPublisher<Progress, Error> {
        return networkService.upload(multipartFormData: multipartFormData, to: url)
    }
}
