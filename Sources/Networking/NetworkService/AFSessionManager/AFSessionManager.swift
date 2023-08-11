import Alamofire
import Foundation
import NetworkInterface

open class AFSessionManager: Session {
    
    public static func `default`(retryProvider: RetryProviderProtocol? = nil,
                                 maxRetryCount: Int = 3,
                                 headersAdapter: HeadersAdapter?
    ) -> AFSessionManager {
        
        let retrier = retryProvider.flatMap { RetrayablePolicy(maxRetryCount: maxRetryCount,
                                                               retryProvider: $0) }
        let interceptor: Interceptor? = (headersAdapter != nil || retrier != nil) ? Interceptor(adapter: headersAdapter, retrier: retrier) : nil 
        let session = AFSessionManager(configuration: URLSessionConfiguration.default,
                                       interceptor: interceptor)
        return session
    }
}
