//
//  File.swift
//
//
//  Created by LEMIN DAHOVICH on 01.03.2023.
//

import Alamofire
import Foundation

open class HeadersAdapter: RequestAdapter {
    private let adaptHeaders: (inout [String: String]) -> Void
    
    public init(adaptHeaders: ((inout [String: String]) -> Void)?) {
        self.adaptHeaders = adaptHeaders ?? { _ in }
    }
    
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        var headers = urlRequest.allHTTPHeaderFields ?? [:]
        
        adaptHeaders(&headers)
        
        urlRequest.allHTTPHeaderFields = headers
        completion(.success(urlRequest))
    }
}
