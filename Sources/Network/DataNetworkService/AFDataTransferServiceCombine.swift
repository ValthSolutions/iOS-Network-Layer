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
    private let errorAdapter: IErrorAdapter
    
    public init(with networkService: AFNetworkServiceCombineProtocol,
                errorAdapter: IErrorAdapter) {
        self.networkService = networkService
        self.errorAdapter = errorAdapter
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
                case NetworkError.error(statusCode: _, data: _):
                    let error = self.errorAdapter.adapt(error)
                    return .networkAdaptableError(error)
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
                case NetworkError.error(statusCode: _, data: _):
                    let error = self.errorAdapter.adapt(error)
                    return .networkAdaptableError(error)
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
                case NetworkError.error(statusCode: _, data: _):
                    let error = self.errorAdapter.adapt(error)
                    return .networkAdaptableError(error)
                case AFError.sessionDeinitialized,
                    AFError.explicitlyCancelled:
                    return .resolvedNetworkFailure(error)
                default:
                    return .networkFailure(.unknown)
                }
            }
            .eraseToAnyPublisher()
    }
    
    open func upload<T, E>(_ endpoint: E,
                           multipartFormData: @escaping (MultipartFormData) -> Void)
    -> AnyPublisher<(Progress, T?), DataTransferError>
    where T: Decodable, T == E.Response, E: ResponseRequestable {
        
        return networkService.upload(endpoint: endpoint,
                                     multipartFormData: multipartFormData)
        .tryMap { progresData -> (Progress, T?) in
            if let data = progresData.1 {
                let result: T = try self.decode(data: data, decoder: endpoint.responseDecoder)
                return (progresData.0, result)
            } else {
                return (progresData.0, nil)
            }
        }
        .mapError { error -> DataTransferError in
            switch error {
            case NetworkError.error(statusCode: _, data: _):
                let error = self.errorAdapter.adapt(error)
                return .networkAdaptableError(error)
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
