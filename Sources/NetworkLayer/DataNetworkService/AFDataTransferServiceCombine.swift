//
//  File.swift
//
//
//  Created by LEMIN DAHOVICH on 01.03.2023.
//

import Foundation
import Alamofire
import Combine
import INetwork

open class AFDataTransferServiceCombine: DataTransferService, AFDataTransferServiceCombineProtocol {
    
    public let decoder: ResponseDecoder
    private let networkService: AFNetworkServiceCombineProtocol
    private let errorAdapter: IErrorAdapter
    private var cancellables = Set<AnyCancellable>()
    
    public init(with networkService: AFNetworkServiceCombineProtocol,
                decoder: ResponseDecoder,
                errorAdapter: IErrorAdapter) {
        self.networkService = networkService
        self.errorAdapter = errorAdapter
        self.decoder = decoder
    }
    
    open func request<T, E>(_ endpoint: E) -> AnyPublisher<T, DataTransferError>
    where T: Decodable, T == E.Response, E: ResponseRequestable {
        return networkService.request(endpoint: endpoint)
            .tryMap { data -> T in
                if data.isEmpty && T.self == EmptyDTO.self {
                    return EmptyDTO() as! T
                } else {
                    let result: T = try self.decode(data: data, decoder: self.decoder)
                    return result
                }
            }
            .mapError { error -> DataTransferError in
                switch error {
                case NetworkError.error(statusCode: _, data: _):
                    let error = self.errorAdapter.adapt(error)
                    return .networkAdaptableError(error)
                case NetworkError.notConnectedToInternet:
                    let error = self.errorAdapter.adapt(error)
                    return .networkAdaptableError(error)
                case AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: let statusCode)):
                    return .networkFailure(.unacceptableStatusCode(statusCode: statusCode))
                case AFError.sessionDeinitialized,
                    AFError.explicitlyCancelled,
                    AFError.responseSerializationFailed(reason: _):
                    return .resolvedNetworkFailure(error)
                default:
                    return .networkFailure(.connectionError(underlying: error))
                }
            }
            .eraseToAnyPublisher()
    }
    
    open func download<T, E>(_ endpoint: E) -> AnyPublisher<T, DataTransferError>
    where T: Decodable, T == E.Response, E: ResponseRequestable {
        return networkService.download(endpoint: endpoint)
            .tryMap { data -> T in
                let result: T = try self.decode(data: data, decoder: self.decoder)
                return result
            }
            .mapError { error -> DataTransferError in
                switch error {
                case NetworkError.error(statusCode: _, data: _):
                    let error = self.errorAdapter.adapt(error)
                    return .networkAdaptableError(error)
                case NetworkError.notConnectedToInternet:
                    let error = self.errorAdapter.adapt(error)
                    return .networkAdaptableError(error)
                case AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: let statusCode)):
                    return .networkFailure(.unacceptableStatusCode(statusCode: statusCode))
                case AFError.sessionDeinitialized,
                    AFError.explicitlyCancelled,
                    AFError.responseSerializationFailed(reason: _):
                    return .resolvedNetworkFailure(error)
                default:
                    return .networkFailure(.connectionError(underlying: error))
                }
            }
            .eraseToAnyPublisher()
    }
    
    open func upload<T, E>(
        _ value: Data,
        _ endpoint: E
    ) -> (AnyPublisher<Progress, DataTransferError>,
          AnyPublisher<T, DataTransferError>)
    where T: Decodable, T == E.Response, E: ResponseRequestable {
        
        let progressSubject = PassthroughSubject<Progress, DataTransferError>()
        let dataSubject = PassthroughSubject<T, DataTransferError>()
        
        let request = networkService.upload(endpoint: endpoint, value)
        
        handleUploadResponse(request,
                             endpoint: endpoint,
                             progressSubject: progressSubject,
                             dataSubject: dataSubject)
        
        return (progressSubject.eraseToAnyPublisher(), dataSubject.eraseToAnyPublisher())
    }
    
    open func upload<T, E>(
        _ endpoint: E,
        multipartFormData: @escaping (MultipartFormData) -> Void
    ) -> (AnyPublisher<Progress, DataTransferError>,
          AnyPublisher<T, DataTransferError>)
    where T: Decodable, T == E.Response, E: ResponseRequestable {
        
        let progressSubject = PassthroughSubject<Progress, DataTransferError>()
        let dataSubject = PassthroughSubject<T, DataTransferError>()
        
        let request = networkService.upload(endpoint: endpoint,
                                            multipartFormData: multipartFormData)
        
        handleUploadResponse(request,
                             endpoint: endpoint,
                             progressSubject: progressSubject,
                             dataSubject: dataSubject)
        
        return (progressSubject.eraseToAnyPublisher(), dataSubject.eraseToAnyPublisher())
    }
}

// MARK: - Private

extension AFDataTransferServiceCombine {
    private func handleUploadResponse<T, E>(
        _ response: AnyPublisher<(Progress, Data?), Error>,
        endpoint: E,
        progressSubject: PassthroughSubject<Progress, DataTransferError>,
        dataSubject: PassthroughSubject<T, DataTransferError>)
    where T: Decodable, T == E.Response, E: ResponseRequestable {
        
        response
            .sink(receiveCompletion: { _ in }) { [weak self] (progress, data) in
                progressSubject.send(progress)
                guard let self else { return }
                if let data = data {
                    do {
                        let result: T = try self.decode(data: data, decoder: decoder)
                        dataSubject.send(result)
                    } catch {
                        dataSubject.send(completion: .failure(.parsing(error)))
                    }
                }
            }
            .store(in: &cancellables)
        
        response
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    progressSubject.send(completion: .finished)
                    dataSubject.send(completion: .finished)
                case .failure(let error):
                    let adaptedError: DataTransferError
                    switch error {
                    case NetworkError.error(statusCode: _, data: _),
                        NetworkError.notConnectedToInternet:
                        adaptedError = .networkAdaptableError(self.errorAdapter.adapt(error))
                    case AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: let statusCode)):
                        adaptedError = .networkFailure(.unacceptableStatusCode(statusCode: statusCode))
                    case AFError.sessionDeinitialized,
                        AFError.explicitlyCancelled,
                        AFError.responseSerializationFailed(reason: _):
                        adaptedError = .resolvedNetworkFailure(error)
                    default:
                        adaptedError = .networkFailure(.connectionError(underlying: error))
                    }
                    
                    progressSubject.send(completion: .failure(adaptedError))
                    dataSubject.send(completion: .failure(adaptedError))
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}
