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

    public func request(endpoint: Requestable) -> AnyPublisher<Data, Error> {
      do {
        let urlRequest = try endpoint.urlRequest(with: config)
          return session.request(urlRequest)
              .publishData()
              .tryMap { response -> Data in

                  guard let data = response.data else {
                      throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
                  }
                  return data
              }
              .eraseToAnyPublisher()
      } catch {
        return Fail(error: NetworkError.urlGeneration)
          .eraseToAnyPublisher()
      }
    }
    
    public func request(_ endpoint: Requestable) -> AnyPublisher<Data, Error> {
        do {
            return session
                .request(endpoint)
                .publishData()
                .tryMap { response -> Data in
                    guard let data = response.data else {
                        throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
                    }
                    return data
                }
            
                .eraseToAnyPublisher() 
        } catch {
            return Fail(error: error as! AFError).eraseToAnyPublisher()
        }
    }
    
    public func download(_ url: URL) -> AnyPublisher<Data, Error> {
        return session
            .download(url).publishData()
            .tryMap { response -> Data in
                guard let destinationURL = response.fileURL else {
                    return
                }
                return .success(destinationURL)
            }
            .eraseToAnyPublisher()
    }
    
    public func upload(_ data: Data, to url: URL) -> AnyPublisher<Data, Error> {
        return session
            .upload(data, to: url)
            .publishData()
            .tryMap { response -> Data in
                guard let data = response.data else {
                    throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
                }
                return data
            }
            .eraseToAnyPublisher()
    }
    
    public func upload(multipartFormData: @escaping (MultipartFormData) -> Void, to url: URL) -> AnyPublisher<Data, Error> {
        return session
            .upload(multipartFormData: multipartFormData, to: url)
            .publishData()
            .tryMap { response -> Data in
                guard let data = response.data else {
                    throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
                }
                return data
            }
            .eraseToAnyPublisher()
    }
}
