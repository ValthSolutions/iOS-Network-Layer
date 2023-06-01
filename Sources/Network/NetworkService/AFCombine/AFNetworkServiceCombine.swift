import Alamofire
import Foundation
import NetworkInterface
import Combine

open class AFNetworkServiceCombine: AFNetworkServiceCombineProtocol {
    
    private let session: Session
    private let logger: Loger
    private let configuration: NetworkConfigurable

    public init(session: Session,
                logger: Loger = DEBUGLog(),
                configuration: NetworkConfigurable) {
        self.session = session
        self.logger = logger
        self.configuration = configuration
    }
    
    open func request(endpoint: Requestable) -> AnyPublisher<Data, Error> {
        do {
            let urlRequest = try endpoint.asURLRequest(config: configuration)
            return session
                .request(urlRequest)
                .publishData()
                .tryMap { [weak self] response -> Data in
                    self?.logger.log(response, endpoint)
                    guard let data = response.data,
                          let statusCode = response.response?.statusCode else {
                        throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
                    }
                    
                    if let statusCode = response.response?.statusCode,
                       let networkStatusCode = NetworkStatusCode(rawValue: statusCode),
                       networkStatusCode.isAcceptable {
                        return data
                    } else {
                        throw NetworkError.error(statusCode: statusCode, data: data)
                    }
                }
                .mapError { error -> Error in
                    if let afError = error as? AFError {
                        return afError.underlyingError ?? NetworkError.generic(error)
                    } else if let networkError = error as? NetworkError {
                        return networkError
                    } else {
                        return NetworkError.generic(error)
                    }
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: NetworkError.urlGeneration).eraseToAnyPublisher()
        }
    }
    
    open func download(endpoint: Requestable) -> AnyPublisher<Data, Error> {
        do {
            let urlRequest = try endpoint.asURLRequest(config: configuration)
            return session
                .download(urlRequest)
                .publishData()
                .tryMap { [weak self] response -> Data in
                    self?.logger.log(response, endpoint)
                    guard let destinationURL = response.fileURL else {
                        throw DataTransferError.noResponse
                    }
                    let data = try Data(contentsOf: destinationURL)
                    guard let statusCode = response.response?.statusCode else {
                        throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
                    }
                    if let statusCode = response.response?.statusCode,
                       let networkStatusCode = NetworkStatusCode(rawValue: statusCode),
                       networkStatusCode.isAcceptable {
                        return data
                    } else {
                        throw NetworkError.error(statusCode: statusCode, data: data)
                    }
                }
                .mapError { error -> Error in
                    if let afError = error as? AFError {
                        return afError.underlyingError ?? NetworkError.generic(error)
                    } else if let networkError = error as? NetworkError {
                        return networkError
                    } else {
                        return NetworkError.generic(error)
                    }
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: NetworkError.urlGeneration).eraseToAnyPublisher()
        }
    }
    
    open func upload(endpoint: Requestable,_  data: Data) -> AnyPublisher<Progress, Error> {
        do {
            let urlRequest = try endpoint.asURLRequest(config: configuration)
            
            return Future<Progress, Error> { [weak self] promise in
                self?.session.upload(data, with: urlRequest).uploadProgress(closure: { progress in
                    promise(.success(progress))
                }).response { response in
                    DEBUGLog().log(response)
                    switch response.result {
                    case .success:
                        break
                    case .failure(let error):
                        if (error.underlyingError != nil) {
                            promise(.failure(error.underlyingError ?? NetworkError.generic(error)))
                        } else {
                            let statusCode = response.response?.statusCode ?? -1
                            let data = response.data ?? Data()
                            promise(.failure(NetworkError.error(statusCode: statusCode, data: data)))
                        }
                    }
                }
            }.eraseToAnyPublisher()
        } catch {
            return Fail(error: NetworkError.urlGeneration).eraseToAnyPublisher()
        }
    }
    
    open func upload(endpoint: Requestable,
                     multipartFormData: @escaping (MultipartFormData) -> Void) -> AnyPublisher<(Progress, Data?), Error> {
        let progressDataSubject = PassthroughSubject<(Progress, Data?), Error>()

        do {
            let urlRequest = try endpoint.asURLRequest(config: configuration)
            session.upload(multipartFormData: multipartFormData, with: urlRequest)
                .uploadProgress { progress in
                    progressDataSubject.send((progress, nil))
                }
                .response { response in
                    DEBUGLog().log(response)
                    switch response.result {
                    case .success(let data):
                        progressDataSubject.send((Progress(totalUnitCount: 1), data))
                        progressDataSubject.send(completion: .finished)
                    case .failure(let error):
                        let data = response.data ?? Data()
                        let statusCode = error.responseCode ?? 400
                        let networkError = NetworkError.error(statusCode: statusCode, data: data)
                        progressDataSubject.send(completion: .failure(networkError))
                    }
                }
        } catch {
            progressDataSubject.send(completion: .failure(NetworkError.urlGeneration))
        }
        
        return progressDataSubject.eraseToAnyPublisher()
    }
}
