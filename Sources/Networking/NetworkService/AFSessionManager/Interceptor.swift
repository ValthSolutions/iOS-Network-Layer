//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 01.03.2023.
//

import Foundation
import Alamofire

open class Interceptor: RequestInterceptor {
    private var adapter: RequestAdapter
    private var retrier: RetryPolicy?

    public  init(adapter: RequestAdapter, retrier: RetryPolicy? = nil) {
        self.adapter = adapter
        self.retrier = retrier
    }
    
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {

    }
    
    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        retrier?.retry(request, for: session, dueTo: error, completion: completion) ?? completion(.doNotRetryWithError(error))

    }
}
