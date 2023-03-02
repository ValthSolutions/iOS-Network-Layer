import Alamofire
import Foundation
import NetworkInterface
import Combine

open class AFNetworkServiceCombine {
    
    public let session: Session
    private let logger: Log
    
    public init(session: Session, logger: Log = DEBUGLog()) {
        self.session = session
        self.logger = logger
    }
    
    private func request(endpoint: Requestable) -> DataResponsePublisher<Data> {
        guard let urlRequest = try? endpoint.asURLRequest() else {
            fatalError("Not correct URLRequest format !!!")
        }
        return session.request(urlRequest).publishData()
    }
    
    public func request(endpoint: Requestable) -> AnyPublisher<Data, Error>  {
        do {
            let urlRequest = try endpoint.asURLRequest()
            return session
                .request(urlRequest)
                .publishData()
                .tryMap { response -> Data in
                    self.logger.log(response)
                    guard let data = response.data else {
                        throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
                    }
                    return data
                }
                .mapError { error -> Error in
                    self.logger.failure(error)
                    return error
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error ).eraseToAnyPublisher()
        }
    }
    
    public func download(endpoint: Requestable) -> AnyPublisher<Data, Error> {
        do {
            let url = try endpoint.asURLRequest()
            return session
                .download(url)
                .publishData()
                .tryMap { response -> Data in
                    guard let destinationURL = response.fileURL else {
                        throw DataTransferError.noResponse
                    }
                    return try Data(contentsOf: destinationURL)
                }
                .mapError { error -> Error in
                    print(error)
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
                self?.logger.log(response)
                switch response.result {
                case .success:
                    break
                case .failure(let error):
                    self?.logger.failure(error)
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
                self?.logger.log(response)
                switch response.result {
                case .success:
                    break
                case .failure(let error):
                    self?.logger.failure(error)
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}
