import Alamofire
import Foundation
import NetworkInterface
import Combine

open class AFNetworkServiceCombine: AFNetworkServiceCombineProtocol {
    
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
 
    public func request(endpoint: Requestable) -> AnyPublisher<Data, Error>  {
        do {
            let urlRequest = try endpoint.asURLRequest(config: configuration)
            return session
                .request(urlRequest)
                .publishData()
                .tryMap { response -> Data in
//                    self.logger.log(response) ///logger is working
                    guard let data = response.data else {
                        throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
                    }
                    return data
                }
                .mapError { error -> Error in
                    return error
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error ).eraseToAnyPublisher()
        }
    }
    
    public func download(endpoint: Requestable) -> AnyPublisher<Data, Error> {
        do {
            let urlRequest = try endpoint.asURLRequest(config: configuration)
            return session
                .download(urlRequest)
                .publishData()
                .tryMap { response -> Data in
//                    self.logger.log(response)  ////logger is working
                    guard let destinationURL = response.fileURL else {
                        throw DataTransferError.noResponse
                    }
                    return try Data(contentsOf: destinationURL)
                }
                .mapError { error -> Error in
                    return error
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error ).eraseToAnyPublisher()
        }
    }
    
    public func upload(_ data: Data, to url: URL) -> AnyPublisher<Progress, Error> {
        Future<Progress, Error> { [weak self] promise in
            self?.session.upload(data, to: url).uploadProgress(closure: { progress in
                promise(.success(progress))
            }).response { response in
                self?.logger.log(response) //doesnt work
//                DEBUGLog().log(response) //and here my logger is working
                switch response.result {
                case .success:
                    break
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    public func upload(multipartFormData: @escaping (MultipartFormData) -> Void,
                       to url: URL) -> AnyPublisher<Progress, Error> {
        Future<Progress, Error> { [weak self] promise in
            self?.session.upload(multipartFormData: multipartFormData,
                                 to: url).uploadProgress(closure: { progress in
                promise(.success(progress))
            }).response { response in
                self?.logger.log(response) //but if i use like this, then it doesnt work
//                DEBUGLog().log(response) //and here my logger is working
                switch response.result {
                case .success:
                    break
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}
