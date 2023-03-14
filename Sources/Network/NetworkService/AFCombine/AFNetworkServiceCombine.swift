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
                    return try Data(contentsOf: destinationURL)
                }
                .mapError { error -> Error in
                    if let afError = error as? AFError {
                        return afError.underlyingError ?? NetworkError.generic(error)
                    } else {
                        return NetworkError.generic(error)
                    }
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: NetworkError.urlGeneration).eraseToAnyPublisher()
        }
    }
    
    open func upload(_ data: Data, to url: URL) -> AnyPublisher<Progress, Error> {
        Future<Progress, Error> { [weak self] promise in
            self?.session.upload(data, to: url).uploadProgress(closure: { progress in
                promise(.success(progress))
            }).response { response in
                DEBUGLog().log(response)
                switch response.result {
                case .success:
                    break
                case .failure(let error):
                    promise(.failure(error.underlyingError ?? NetworkError.generic(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    open func upload(multipartFormData: @escaping (MultipartFormData) -> Void,
                     to url: URL) -> AnyPublisher<Progress, Error> {
        Future<Progress, Error> { [weak self] promise in
            self?.session.upload(multipartFormData: multipartFormData,
                                 to: url).uploadProgress(closure: { progress in
                promise(.success(progress))
            }).response { response in
                DEBUGLog().log(response)
                switch response.result {
                case .success:
                    break
                case .failure(let error):
                    promise(.failure(NetworkError.generic(error)))
                }
            }
            .validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                case .success:
                    break
                case .failure(let error):
                    if error.isExplicitlyCancelledError {
                        promise(.failure(NetworkError.cancelled))
                    } else if error.isSessionTaskError || error.isResponseValidationError {
                        promise(.failure(NetworkError.generic(error)))
                    } else {
                        let statusCode = response.response?.statusCode ?? -1
                        let data = response.data ?? Data()
                        promise(.failure(NetworkError.error(statusCode: statusCode, data: data)))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
}
