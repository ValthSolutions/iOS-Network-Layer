//
//  File.swift
//
//
//  Created by LEMIN DAHOVICH on 01.03.2023.
//

import Alamofire
import Foundation

open class HeadersAdapter {
    private let adaptHeaders: (inout [String: String]) -> Void
    
    public init(adaptHeaders: ((inout [String: String]) -> Void)?) {
        self.adaptHeaders = adaptHeaders ?? { _ in }
    }
    
    open func generateHeaders(for urlRequest: URLRequest) -> [String: String] {
        var headers = urlRequest.allHTTPHeaderFields ?? [:]
        adaptHeaders(&headers)
        return headers
    }
    
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var modifiedURLRequest = urlRequest
        modifiedURLRequest.allHTTPHeaderFields = generateHeaders(for: modifiedURLRequest)
        completion(.success(modifiedURLRequest))
    }
}
