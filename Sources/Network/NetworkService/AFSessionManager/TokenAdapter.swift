//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 01.03.2023.
//

import Alamofire
import Foundation

public class TokenAdapter: RequestAdapter {
    private let setToken: (inout [String: String]) -> Void
    
    public init(setToken: ((inout [String: String]) -> Void)?) {
          self.setToken = setToken ?? { headers in }
    }
    
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        var headers = urlRequest.allHTTPHeaderFields ?? [:]
        
        setToken(&headers)
        
        urlRequest.allHTTPHeaderFields = headers
        completion(.success(urlRequest))
    }
}
