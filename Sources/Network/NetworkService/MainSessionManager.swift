
import Alamofire
import Foundation

public class MainSessionManager: Session {
    
    public static func `default`(setToken: @escaping (inout [String: String]) -> Void) -> MainSessionManager {
        let adapter = TokenAdapter(setToken: setToken)
        let interceptor = Intercector(adapter: adapter)
        let session = MainSessionManager(configuration: URLSessionConfiguration.default, interceptor: interceptor)
        return session
    }
}

public class Intercector: RequestInterceptor {
    private var adapter: RequestAdapter
    
    public  init(adapter: RequestAdapter) {
        self.adapter = adapter
    }
    
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        adapter.adapt(urlRequest, for: session, completion: completion)
    }
}

public class TokenAdapter: RequestAdapter {
    private let setToken: (inout [String: String]) -> Void
    
    public init(setToken: @escaping (inout [String: String]) -> Void) {
        self.setToken = setToken
    }
    
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        var headers = urlRequest.allHTTPHeaderFields ?? [:]
        
        setToken(&headers)
        
        urlRequest.allHTTPHeaderFields = headers
        completion(.success(urlRequest))
    }
}
//MARK: - initialization
/*
 let manager = MainSessionManager.default { headers in
     headers["auth-token"] = "your_token_value"
 }
 */
