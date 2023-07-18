//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 28.02.2023.
//

import Foundation
import Alamofire
import NetworkInterface

open class RetryPolicy: RequestRetrier {
    private let maxRetryCount: Int
    private let retryProvider: RetryProviderProtocol?
    private var retryCount = [URL: Int]()
    private var isRefreshingToken = false
    private var requestsToRetry: [(RetryResult) -> Void] = []
    
    init(maxRetryCount: Int, retryProvider: RetryProviderProtocol?) {
        self.maxRetryCount = maxRetryCount
        self.retryProvider = retryProvider
    }
    
    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        
        guard let url = request.request?.url,
              let response = request.task?.response as? HTTPURLResponse else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        guard let retryCount = retryCount[url], retryCount < maxRetryCount else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        if let retryProvider = retryProvider, !isRefreshingToken {
            requestsToRetry.append(completion)
            
            isRefreshingToken = true
            retryProvider.retry(statusCode: response.statusCode) { [weak self] isSuccess in
                guard let self else { return }
                
                isRefreshingToken = false
                if isSuccess {
                    self.retryCount[url] = retryCount + 1
                    self.requestsToRetry.forEach { $0(.retry) }
                } else {
                    self.requestsToRetry.forEach { $0(.doNotRetryWithError(error)) }
                }
                self.requestsToRetry.removeAll()
            }
        } else if isRefreshingToken {
            requestsToRetry.append(completion)
        } else {
            completion(.doNotRetryWithError(error))
        }
    }
}
