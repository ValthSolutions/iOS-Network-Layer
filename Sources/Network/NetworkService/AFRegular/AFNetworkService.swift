
import Alamofire
import Foundation
import NetworkInterface

open class AFNetworkService: AFNetworkServiceProtocol {
    
    private let session: Session
    private let logger: Log
    private let configuration: NetworkConfigurable
    
    public init(session: Session,
                logger: Log = DEBUGLog(),
                configuration: NetworkConfigurable) {
        self.session = session
        self.logger = logger
        self.configuration = configuration
    }

    public func request(endpoint: Requestable) async throws -> Data {
        let urlRequest = try endpoint.asURLRequest(config: configuration)
        let response = session.request(urlRequest).serializingData()
//        await logger.log(response.response)
        return try await response.value
    }
    
    public func download(endpoint: Requestable) async throws -> Data {
        let urlRequest = try endpoint.asURLRequest(config: configuration)
        let response = session.download(urlRequest).serializingData()
//        await logger.log(response.response)
        return try await response.value
    }
    
    public func upload(_ data: Data, to url: URL) async throws -> Progress {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Progress, Error>) in
            self.session.upload(data, to: url).uploadProgress(closure: { progress in
                continuation.resume(returning: progress)
            }).response { response in
//                self.logger.log(response)
                switch response.result {
                case .success:
                    break
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public func upload(multipartFormData: @escaping (MultipartFormData) -> Void,
                       to url: URL) async throws -> Progress {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Progress, Error>) in
            self.session.upload(multipartFormData: multipartFormData, to: url).uploadProgress(closure: { progress in
                continuation.resume(returning: progress)
            }).response { response in
//                self.logger.log(response)
                switch response.result {
                case .success:
                    break
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
