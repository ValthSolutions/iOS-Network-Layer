import Alamofire
import Foundation
import NetworkInterface

open class AFSessionManager: Session {
    
    public static func `default`(adaptHeaders: ((inout [String: String]) -> Void)?,
                                 retryProvider: RetryProviderProtocol? = nil,
                                 maxRetryCount: Int = 3) -> AFSessionManager {
        
        let adapter = adaptHeaders.flatMap { HeadersAdapter(adaptHeaders: $0) }
        let retrier = retryProvider.flatMap { RetrayablePolicy(maxRetryCount: maxRetryCount, retryProvider: $0) }
        let interceptor: Interceptor? = (adapter != nil || retrier != nil) ? Interceptor(adapter: adapter,
                                                                                         retrier: retrier) : nil
        let session = AFSessionManager(configuration: URLSessionConfiguration.default,
                                       interceptor: interceptor)
        return session
    }
}
