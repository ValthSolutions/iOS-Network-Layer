import Alamofire
import Foundation
import NetworkInterface
import Combine

open class AFNetworkServiceCombine {
    
    public let session: Session 
    
    public init(session: Session = Session()) {
        self.session = session
    }
    
    private func request(endpoint: Requestable) -> DataResponsePublisher<Data> {
        guard let urlRequest = try? endpoint.asURLRequest() else {
            fatalError("Not correct URLRequest format !!!")
        }
        return session.request(urlRequest).publishData()
    }
    func printJSON(from data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
        } catch {
            print("Error parsing JSON: \(error.localizedDescription)")
        }
    }
    public func request(endpoint: Requestable) -> AnyPublisher<Data, Error>  {
        do {
            let urlRequest = try endpoint.asURLRequest()
            return session
                .request(urlRequest)
                .publishData()
                .tryMap { response -> Data in
                    guard let data = response.data else {
                        throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
                    }
                    return data
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
}
//    public func request(_ endpoint: Requestable) {
////        do {
////            let urlRequest = try endpoint.asURLRequest(with: config)
////            return session
////                .request(urlRequest)
////                .publishData()
////                .tryMap { response -> Data in
////                    guard let data = response.data else {
////                        throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
////                    }
////                    return data
////                }
////                .mapError { error -> Error in
////                    return error as Error
////                }
////                .eraseToAnyPublisher()
////        } catch {
////            return Fail(error: error as! Error).eraseToAnyPublisher()
////        }
//    }
//
//    public func download(_ url: URL) {
////        return session
////            .download(url).publishData()
////            .tryMap { response -> Data in
////                guard let destinationURL = response.fileURL else {
////                    return
////                }
////                return .success(destinationURL)
////            }
////            .eraseToAnyPublisher()
//    }
//
//    public func upload(_ data: Data, to url: URL) {
////        return session
////            .upload(data, to: url)
////            .publishData()
////            .tryMap { response -> Data in
////                guard let data = response.data else {
////                    throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
////                }
////                return data
////            }
////            .eraseToAnyPublisher()
//    }
//
//    public func upload(multipartFormData: @escaping (MultipartFormData) -> Void, to url: URL)  {
////        return session
////            .upload(multipartFormData: multipartFormData, to: url)
////            .publishData()
////            .tryMap { response -> Data in
////                guard let data = response.data else {
////                    throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
////                }
////                return data
////            }
////            .eraseToAnyPublisher()
//    }
//}
