//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 28.02.2023.
//

import Alamofire
import Foundation

open class RetryPolicy: RequestRetrier {
    private let maxRetryCount: Int
    
    init(maxRetryCount: Int) {
        self.maxRetryCount = maxRetryCount
    }
    
    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        
        guard let response = request.task?.response as? HTTPURLResponse,
              (response.statusCode == 401 || response.statusCode == 403) else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        completion(.retryWithDelay(1.0))
    }
}
