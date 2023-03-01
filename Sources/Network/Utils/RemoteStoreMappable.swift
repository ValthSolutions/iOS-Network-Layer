import Alamofire
import ObjectMapper
import Foundation
import NetworkInterface

open class RemoteStoreCodable<Item: Decodable>: AFNetworkService, RemoteStoreObjects {

    open func send(request: RequestProvider,
                     keyPath: String? = nil,
                     responseObject: @escaping (Result<Item, Error>) -> Void)
    {
        send(request: request).responseDecodable(decoder: KeyPathDecoder(keyPath)) { (response: AFDataResponse<Item>) -> Void in
            responseObject(self.handler.handle(response))
        }
    }
    
    open func send(request: RequestProvider,
                     keyPath: String? = nil,
                     responseArray: @escaping (Result<[Item], Error>) -> Void)
    {
        send(request: request).responseDecodable(decoder: KeyPathDecoder(keyPath)) { (response: AFDataResponse<[Item]>) -> Void in
            responseArray(self.handler.handle(response))
        }
    }
}

open class RemoteStoreMappable<Item: BaseMappable>: AFNetworkService, RemoteStoreObjects {

    open func send(request: RequestProvider,
                        keyPath: String? = nil,
                        responseObject: @escaping (Result<Item, Error>) -> Void)
    {
        send(request: request).responseObject(keyPath: keyPath) { (response: AFDataResponse<Item>) -> Void in
            responseObject(self.handler.handle(response))
        }
    }
    
    open func send(request: RequestProvider,
                     keyPath: String? = nil,
                     responseArray: @escaping (Result<[Item], Error>) -> Void)
    {
        send(request: request).responseArray(keyPath: keyPath) { (response: AFDataResponse<[Item]>) -> Void in
            responseArray(self.handler.handle(response))
        }
    }
}


