import Alamofire
import Foundation
import NetworkInterface
import Combine

open class AFNetworkServiceCombine {
     
    private let config: NetworkConfigurable
    public var session: Session
    
    public init(config: NetworkConfigurable,
                session: Session) {
        self.session = session
        self.config = config
    }

    public func request(endpoint: Requestable) -> DataRequest {
        guard let urlRequest = try? endpoint.asURLRequest(with: config) else {
            fatalError("Not correct URLRequest format !!!")
        }
        return session.request(urlRequest).validate()
    }
    
    public func request(endpoint: Requestable) -> AnyPublisher<Data, AFError>  {
       return request(endpoint: endpoint).publishData().value()
    }
    
    public func request(_ endpoint: Requestable) {
//        do {
//            let urlRequest = try endpoint.asURLRequest(with: config)
//            return session
//                .request(urlRequest)
//                .publishData()
//                .tryMap { response -> Data in
//                    guard let data = response.data else {
//                        throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
//                    }
//                    return data
//                }
//                .mapError { error -> Error in
//                    return error as Error
//                }
//                .eraseToAnyPublisher()
//        } catch {
//            return Fail(error: error as! Error).eraseToAnyPublisher()
//        }
    }
    
    public func download(_ url: URL) {
//        return session
//            .download(url).publishData()
//            .tryMap { response -> Data in
//                guard let destinationURL = response.fileURL else {
//                    return
//                }
//                return .success(destinationURL)
//            }
//            .eraseToAnyPublisher()
    }
    
    public func upload(_ data: Data, to url: URL) {
//        return session
//            .upload(data, to: url)
//            .publishData()
//            .tryMap { response -> Data in
//                guard let data = response.data else {
//                    throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
//                }
//                return data
//            }
//            .eraseToAnyPublisher()
    }
    
    public func upload(multipartFormData: @escaping (MultipartFormData) -> Void, to url: URL)  {
//        return session
//            .upload(multipartFormData: multipartFormData, to: url)
//            .publishData()
//            .tryMap { response -> Data in
//                guard let data = response.data else {
//                    throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
//                }
//                return data
//            }
//            .eraseToAnyPublisher()
    }
}
