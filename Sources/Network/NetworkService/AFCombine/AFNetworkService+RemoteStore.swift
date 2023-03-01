//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 01.03.2023.
//
import NetworkInterface
import Alamofire
import Foundation

extension AFNetworkService: RemoteStore {
    
    public func send(request: RequestProvider) -> DataRequest {
        guard let urlRequest = try? request.asURLRequest() else {
            fatalError("Not correct URLRequest format !!!")
        }
        return session.request(urlRequest).validate()
    }
   
    public func send(request: RequestProvider, responseString: @escaping (Result<String, Error>) -> Void) {
        send(request: request).responseString { (response: AFDataResponse<String>) -> Void in
            responseString(self.handler.handle(response))
        }
    }
    
    public func send(request: RequestProvider, responseData: @escaping (Result<Data, Error>) -> Void) {
        send(request: request).responseData { (response: AFDataResponse<Data>) -> Void in
            responseData(self.handler.handle(response))
        }
    }
    
    public func send(request: RequestProvider, responseJSON: @escaping (Result<Any, Error>) -> Void) {
        send(request: request).responseJSON { (response: AFDataResponse<Any>) -> Void in
            responseJSON(self.handler.handle(response))
        }
    }
    
    public func send<Item>(request: RequestProvider, keyPath: String?, responseItem: @escaping (Result<Item, Error>) -> Void) {
        send(request: request).responseItem(keyPath: keyPath) { (response: AFDataResponse<Item>) -> Void  in
            responseItem(self.handler.handle(response))
        }
    }
}
