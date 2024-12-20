import Alamofire
import Foundation
import INetwork

open class AFSessionManager: Session {
    
    public static func `default`(retryProvider: RetryProviderProtocol? = nil,
                                 maxRetryCount: Int = 3,
                                 headersAdapter: HeadersAdapter?,
                                 configuration: URLSessionConfiguration = .default
    ) -> AFSessionManager {
        
        let retrier = retryProvider.flatMap { RetrayablePolicy(maxRetryCount: maxRetryCount,
                                                               retryProvider: $0) }
        let interceptor: Interceptor? = Interceptor(adapter: headersAdapter, retrier: retrier)
        let session = AFSessionManager(configuration: configuration,
                                       interceptor: interceptor)
        return session
    }
}
