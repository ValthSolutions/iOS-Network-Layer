//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 28.02.2023.
//
import Alamofire
import Foundation

struct Keys {
    static let authorization = "Authorization"
    static let accept = "Accept"
    static let contentType = "Content-Type"
}

struct DefaultHTTPHeaders {

    static var main: HTTPHeaders {
        var header = self.default
        
        let accept = HTTPHeader(name: Keys.accept, value: "application/json")
        let contentType = HTTPHeader(name: Keys.contentType, value: "application/json")
        
        header.add(accept)
        header.add(contentType)
        
        return header
    }

    static let `default` = HTTPHeaders.default

    static func adapt(_ urlRequest: URLRequest) -> URLRequest {
        var urlRequest = urlRequest

        main.forEach {
            if let headers = urlRequest.allHTTPHeaderFields, headers[$0.name] == nil {
                urlRequest.setValue($0.value, forHTTPHeaderField: $0.name)
            }
        }
        return urlRequest
    }
}
