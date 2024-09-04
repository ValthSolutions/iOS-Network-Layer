import Foundation
import Alamofire
import INetwork

extension Notification.Name {
    public static let maxRetryCountReached = Notification.Name("maxRetryCountReached")
}

open class RetrayablePolicy: RequestRetrier {
    private let maxRetryCount: Int
    private let retryProvider: RetryProviderProtocol?
    private var retryInfo = [URL: (count: Int, completions: [(RetryResult) -> Void])]()
    private var urlsRefreshing = Set<URL>()
    
    init(maxRetryCount: Int, retryProvider: RetryProviderProtocol?) {
        self.maxRetryCount = maxRetryCount
        self.retryProvider = retryProvider
    }
    
    public func retry(_ request: Request,
                      for session: Session,
                      dueTo error: Error,
                      completion: @escaping (RetryResult) -> Void) {
        guard let url = request.request?.url,
              let response = request.task?.response as? HTTPURLResponse else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        if retryInfo[url] == nil {
            retryInfo[url] = (count: 0, completions: [])
        }
        
        guard let currentRetryInfo = retryInfo[url] else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        if currentRetryInfo.count >= maxRetryCount {
            NotificationCenter.default.post(name: .maxRetryCountReached, object: nil, userInfo: ["url": url])
            completion(.doNotRetryWithError(error))
            return
        }
        
        if let retryProvider = retryProvider, !urlsRefreshing.contains(url) {
            retryInfo[url]?.completions.append(completion)
            
            urlsRefreshing.insert(url)
            retryProvider.retry(statusCode: response.statusCode) { [weak self] isSuccess in
                guard let self = self, let currentRetryInfo = self.retryInfo[url] else { return }
                
                self.urlsRefreshing.remove(url)
                
                if isSuccess {
                    self.retryInfo[url]?.count += 1
                    currentRetryInfo.completions.forEach { $0(.retry) }
                } else {
                    currentRetryInfo.completions.forEach { $0(.doNotRetryWithError(error)) }
                }
                self.retryInfo[url]?.completions.removeAll()
            }
        } else if urlsRefreshing.contains(url) {
            retryInfo[url]?.completions.append(completion)
        } else {
            completion(.doNotRetryWithError(error))
        }
    }
}
