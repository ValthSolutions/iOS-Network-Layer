import Alamofire
import Foundation
import NetworkInterface

open class AFSessionManager: Session {
    
    public static func `default`(adaptHeaders: ((inout [String: String]) -> Void)?) -> AFSessionManager {
        var interceptor: Interceptor?
        var adapter: HeadersAdapter?
        
        if let adaptHeaders = adaptHeaders {
            adapter = HeadersAdapter(adaptHeaders: adaptHeaders)
            interceptor = Interceptor(adapter: adapter!)
        }
        
        let session = AFSessionManager(configuration: URLSessionConfiguration.default, interceptor: interceptor)
        return session
    }
}
