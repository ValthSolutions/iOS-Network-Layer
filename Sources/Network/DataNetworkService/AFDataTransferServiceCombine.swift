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

open class AFDataTransferServiceCombine: DataTransferService, AFDataTransferServiceCombineProtocol {
    
    private let networkService: AFNetworkServiceCombineProtocol
    
    public init(with networkService: AFNetworkServiceCombineProtocol) {
        self.networkService = networkService
    }
    
    open func request<T, E>(_ endpoint: E) -> AnyPublisher<T, DataTransferError>
    where T: Decodable, T == E.Response, E: ResponseRequestable {
        return networkService.request(endpoint: endpoint)
            .tryMap { data -> T in
                let result: T = try self.decode(data: data, decoder: endpoint.responseDecoder)
                return result
            }
            .mapError { error -> DataTransferError in
                switch error {
                case AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: let statusCode)):
                    return .networkFailure(.unacceptableStatusCode(statusCode: statusCode))
                case AFError.sessionDeinitialized,
                    AFError.explicitlyCancelled,
                    AFError.responseSerializationFailed(reason: _):
                    return .resolvedNetworkFailure(error)
                default:
                    return .networkFailure(.unknown)
                }
            }
            .eraseToAnyPublisher()
    }
    
    open func download<T, E>(_ endpoint: E) -> AnyPublisher<T, DataTransferError>
    where T: Decodable, T == E.Response, E: ResponseRequestable {
        return networkService.download(endpoint: endpoint)
            .tryMap { data -> T in
                let result: T = try self.decode(data: data, decoder: endpoint.responseDecoder)
                return result
            }
            .mapError { error -> DataTransferError in
                switch error {
                case AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: let statusCode)):
                    return .networkFailure(.unacceptableStatusCode(statusCode: statusCode))
                case AFError.sessionDeinitialized,
                    AFError.explicitlyCancelled,
                    AFError.responseSerializationFailed(reason: _):
                    return .resolvedNetworkFailure(error)
                default:
                    return .networkFailure(.unknown)
                }
            }
            .eraseToAnyPublisher()
    }
    
    open func upload(_ value: String, url: URL) -> AnyPublisher<Progress, DataTransferError> {
        let encodedData = try! self.encode(value, encoder: JSONEncoderData())
        return networkService.upload(encodedData, to: url)
            .mapError { error -> DataTransferError in
                switch error {
                case AFError.sessionDeinitialized,
                    AFError.explicitlyCancelled:
                    return .resolvedNetworkFailure(error)
                default:
                    return .networkFailure(.unknown)
                }
            }
            .eraseToAnyPublisher()
    }
    
    open func upload(multipartFormData: @escaping (MultipartFormData) -> Void,
                     to url: URL) -> AnyPublisher<Progress, DataTransferError> {
        return networkService.upload(multipartFormData: multipartFormData, to: url)
            .mapError { error -> DataTransferError in
                switch error {
                case AFError.sessionDeinitialized,
                    AFError.explicitlyCancelled:
                    return .resolvedNetworkFailure(error)
                default:
                    return .networkFailure(.unknown)
                }
            }
            .eraseToAnyPublisher()
    }
}
