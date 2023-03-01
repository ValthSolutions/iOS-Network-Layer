//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 01.03.2023.
//

import Foundation
import Alamofire

public class Interceptor: RequestInterceptor {
    private var adapter: RequestAdapter
    
    public  init(adapter: RequestAdapter) {
        self.adapter = adapter
    }
    
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        adapter.adapt(urlRequest, for: session, completion: completion)
    }
}
