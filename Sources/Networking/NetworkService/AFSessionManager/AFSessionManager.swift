import Alamofire
import Foundation
import NetworkInterface

open class AFSessionManager: Session {
    
    public static func `default`(adaptHeaders: ((inout [String: String]) -> Void)?,
                                 retryProvider: RetryProviderProtocol? = nil,
                                 maxRetryCount: Int = 3) -> AFSessionManager {
        var adapter: HeadersAdapter?
        var retrier: RetryPolicy?
        var interceptor: Interceptor?
        
        if let adaptHeaders = adaptHeaders {
            adapter = HeadersAdapter(adaptHeaders: adaptHeaders)
            if let retryProvider = retryProvider {
                retrier = RetryPolicy(maxRetryCount: maxRetryCount,
                                      retryProvider: retryProvider)
            }
            interceptor = Interceptor(adapter: adapter!, retrier: retrier)
        }
        
        let session = AFSessionManager(configuration: URLSessionConfiguration.default,
                                       interceptor: interceptor)
        return session
    }
}
