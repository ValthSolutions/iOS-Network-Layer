import Alamofire
import Foundation
import NetworkInterface

open class RemoteStoreAlamofire: RemoteStore {
 
    public var handler: BaseHandler
    public var session: Alamofire.Session
    
    public init(session: Alamofire.Session, handler: BaseHandler) {
        self.session = session
        self.handler = handler
    }
    
    open func send(request: RequestProvider) -> DataRequest {
        guard let urlRequest = try? request.asURLRequest() else {
            fatalError("Not correct URLRequest format !!!")
        }
        return session.request(urlRequest).validate()
    }
   
    open func send(request: RequestProvider, responseString: @escaping (Result<String, Error>) -> Void) {
        send(request: request).responseString { (response: AFDataResponse<String>) -> Void in
            responseString(self.handler.handle(response))
        }
    }
    
    open func send(request: RequestProvider, responseData: @escaping (Result<Data, Error>) -> Void) {
        send(request: request).responseData { (response: AFDataResponse<Data>) -> Void in
            responseData(self.handler.handle(response))
        }
    }
    
    open func send(request: RequestProvider, responseJSON: @escaping (Result<Any, Error>) -> Void) {
        send(request: request).responseJSON { (response: AFDataResponse<Any>) -> Void in
            responseJSON(self.handler.handle(response))
        }
    }
    
    open func send<Item>(request: RequestProvider, keyPath: String?, responseItem: @escaping (Result<Item, Error>) -> Void) {
        send(request: request).responseItem(keyPath: keyPath) { (response: AFDataResponse<Item>) -> Void  in
            responseItem(self.handler.handle(response))
        }
    }
}
