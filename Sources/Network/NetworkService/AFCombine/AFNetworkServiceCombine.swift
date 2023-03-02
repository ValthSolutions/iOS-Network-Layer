import Alamofire
import Foundation
import NetworkInterface
import Combine

open class AFNetworkServiceCombine {
    
    public let session: Session
    
    public init(session: Session) {
        self.session = session
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
    
    public func download(endpoint: Requestable) -> AnyPublisher<Data, Error> {
        do {
            let url = try endpoint.asURLRequest()
            session.interceptor?.adapt(url, for: session, completion: { res in
                switch res {
                case .success(let resss):
                    print(resss)
                case .failure(let err):
                    print(err)
                }
            })
            
            return session
                .download(url).publishData()
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
                switch response.result {
                case .success:
                    break
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    public func upload(multipartFormData: @escaping (MultipartFormData) -> Void, to url: URL) -> AnyPublisher<Progress, Error> {
        Future<Progress, Error> { [weak self] promise in
            self?.session.upload(multipartFormData: multipartFormData, to: url).uploadProgress(closure: { progress in
                promise(.success(progress))
            }).response { response in
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
//        .upload(multipartFormData: multipartFormData, to: url)


//        .responseDecodable(of: Double.self) { response in
//            switch response.result {
//            case .success(let value):
//                promise(.success(value))
//            case .failure(let error):
//                promise(.failure(error))
//            }
//        }
//    }.eraseToAnyPublisher()

//    //return -> AnyPublisher<Decodable, Error>
//    public func upload(_ data: Data, to url: URL) -> UploadRequest {
//        return session.upload(data, to: url).responseDecodable(completionHandler: //)
//    }

//



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

//func printJSON(from data: Data) {
//    do {
//        let jsonObject = try JSONSerialization.jsonObject(with: data)
//        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
//        if let jsonString = String(data: jsonData, encoding: .utf8) {
//            print(jsonString)
//        }
//    } catch {
//        print("Error parsing JSON: \(error.localizedDescription)")
//    }
//}
