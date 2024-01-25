
import Alamofire
import Foundation
import NetworkInterface

open class AFNetworkService: AFReachableNetworkService, AFNetworkServiceProtocol {
    
    public let encoder: JSONEncoder
    private let session: Session
    private let logger: Loger
    private let fetchConfiguration: () -> NetworkConfigurable

    public init(session: Session,
                logger: Loger = DEBUGLog(),
                encoder: JSONEncoder,
                fetchConfiguration: @escaping () -> NetworkConfigurable) {
        self.session = session
        self.logger = logger
        self.encoder = encoder
        self.fetchConfiguration = fetchConfiguration
    }
    
    open func request(endpoint: Requestable) async throws -> Data {
        guard isInternetAvailable() else {
            throw NetworkError.notConnectedToInternet
        }
        let urlRequest = try endpoint.asURLRequest(config: fetchConfiguration(), encoder: encoder)
        let response = session.request(urlRequest).validate().serializingData()
        await logger.log(response.response, endpoint)
        
        switch await response.result {
        case .success(let data):
            return data
        case .failure(let error):
            if error.isExplicitlyCancelledError {
                throw NetworkError.cancelled
            } else if error.isSessionTaskError || error.isResponseValidationError {
                throw NetworkError.generic(error)
            } else {
                let statusCode = await response.response.response?.statusCode ?? -1
                let data = try await response.value
                throw NetworkError.error(statusCode: statusCode, data: data)
            }
        }
    }
    
    open func download(endpoint: Requestable) async throws -> Data {
        guard isInternetAvailable() else {
            throw NetworkError.notConnectedToInternet
        }
        let urlRequest = try endpoint.asURLRequest(config: fetchConfiguration(), encoder: encoder)
        let response = session.download(urlRequest).serializingData()
        await logger.log(response.response, endpoint)
        
        switch await response.result {
        case .success(let data):
            return data
        case .failure(let error):
            if error.isExplicitlyCancelledError {
                throw NetworkError.cancelled
            } else if error.isSessionTaskError || error.isResponseValidationError {
                throw NetworkError.generic(error)
            } else {
                let statusCode = await response.response.response?.statusCode ?? -1
                let data = try await response.value
                throw NetworkError.error(statusCode: statusCode, data: data)
            }
        }
    }
    
    open func upload(_ data: Data, to url: URL) async throws -> Progress {
        guard isInternetAvailable() else {
            throw NetworkError.notConnectedToInternet
        }
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Progress, Error>) in
            self.session.upload(data, to: url).uploadProgress(closure: { progress in
                continuation.resume(returning: progress)
            }).response { response in
                self.logger.log(response, nil)
                switch response.result {
                case .success:
                    break
                case .failure(let error):
                    if let statusCode = error.responseCode {
                        let data = error.downloadResumeData ?? Data()
                        let networkError = NetworkError.error(statusCode: statusCode, data: data)
                        continuation.resume(throwing: networkError)
                    } else {
                        continuation.resume(throwing: NetworkError.generic(error))
                    }
                }
            }
        }
    }
    
    open func upload(multipartFormData: @escaping (MultipartFormData) -> Void,
                     to url: URL) async throws -> Progress {
        guard isInternetAvailable() else {
            throw NetworkError.notConnectedToInternet
        }
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Progress, Error>) in
            self.session.upload(multipartFormData: multipartFormData, to: url).uploadProgress(closure: { progress in
                continuation.resume(returning: progress)
            }).response { response in
                switch response.result {
                case .success(_):
                    break
                case .failure(let error):
                    switch true {
                    case error.isExplicitlyCancelledError:
                        continuation.resume(throwing: NetworkError.cancelled)
                    case error.isSessionTaskError || error.isResponseValidationError:
                        continuation.resume(throwing: NetworkError.generic(error))
                    default:
                        let statusCode = response.response?.statusCode ?? -1
                        let data = response.data ?? Data()
                        continuation.resume(throwing: NetworkError.error(statusCode: statusCode, data: data))
                    }
                }
            }
        }
    }
}
