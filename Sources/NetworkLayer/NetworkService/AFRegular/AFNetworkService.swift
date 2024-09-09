import Alamofire
import Foundation
import INetwork

open class AFNetworkService: AFReachableNetworkService, AFNetworkServiceProtocol {
    
    public let encoder: JSONEncoder
    private let session: Session
    private let logger: Loger
    private let fetchConfiguration: () -> NetworkConfigurable
    
    public init(session: Session,
                logLevel: LogLevel = .release,
                encoder: JSONEncoder,
                fetchConfiguration: @escaping () -> NetworkConfigurable) {
        self.session = session
        self.logger = logLevel.logger
        self.encoder = encoder
        self.fetchConfiguration = fetchConfiguration
    }
    
    // MARK: - Stream
    open func streamRequest(endpoint: Requestable) async throws -> DataStreamRequest {
        guard isInternetAvailable() else {
            throw NetworkError.notConnectedToInternet
        }
        let urlRequest = try endpoint.asURLRequest(config: fetchConfiguration(), encoder: encoder)
        let streamRequest = session.streamRequest(urlRequest)
        
        logger.logRequestInitiation(urlRequest)
        
        streamRequest.responseStream { [weak self] stream in
            switch stream.event {
            case .stream(let data):
                self?.logger.logStreamChunk(data)
                
            case .complete(let completion):
                self?.logger.logStreamCompletion(completion)
            }
        }
        return streamRequest
    }
    
    open func request(endpoint: Requestable) async throws -> Data {
        guard isInternetAvailable() else {
            throw NetworkError.notConnectedToInternet
        }
        
        let urlRequest = try endpoint.asURLRequest(config: fetchConfiguration(), encoder: encoder)
        let response = session.request(urlRequest).validate().serializingData()
        await logger.log(response.response, endpoint)
        return try await handleResponse(response)
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
    
    open func upload(multipartFormData: @escaping (MultipartFormData) -> Void, to url: URL) async throws -> Data? {
        guard isInternetAvailable() else {
            throw NetworkError.notConnectedToInternet
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.session.upload(multipartFormData: multipartFormData, to: url).response { [weak self] response in
                self?.logger.log(response, nil)
                switch response.result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    if error.isExplicitlyCancelledError {
                        continuation.resume(throwing: NetworkError.cancelled)
                    } else if error.isSessionTaskError || error.isResponseValidationError {
                        continuation.resume(throwing: NetworkError.generic(error))
                    } else {
                        let statusCode = response.response?.statusCode ?? -1
                        let data = response.data ?? Data()
                        continuation.resume(throwing: NetworkError.error(statusCode: statusCode, data: data))
                    }
                }
            }
        }
    }
}

extension AFNetworkService {
    
    private func handleResponse(_ task: DataTask<Data>) async throws -> Data {
        
        switch await task.result {
        case .success(let data):
            return data
        case .failure(let error):
            throw await handleAFError(error, response: task.response.response)
        }
    }
    
    private func handleAFError(_ error: AFError, response: HTTPURLResponse?) -> NetworkError {
        let networkError: NetworkError
        if error.isExplicitlyCancelledError {
            networkError = .cancelled
        } else if error.isRequestRetryError {
            networkError = .retryError(underlying: error, statusCode: response?.statusCode)
        } else if error.isSessionTaskError {
            networkError = .connectionError(underlying: error)
        } else if error.isResponseValidationError, let statusCode = response?.statusCode {
            networkError = .unacceptableStatusCode(statusCode: statusCode)
        } else if let statusCode = response?.statusCode {
            networkError = .error(statusCode: statusCode, data: nil)
        } else {
            networkError = .generic(error)
        }
        logger.failure(error)
        return networkError
    }
}
