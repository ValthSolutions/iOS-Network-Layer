
import Alamofire
import Foundation

//MARK: - initialization
/*
 let manager = MainSessionManager.default { headers in
     headers["auth-token"] = "your_token_value"
 }
 */

public class AFSessionManager: Session {
    
    public static func `default`(setToken: ((inout [String: String]) -> Void)? = nil) -> AFSessionManager {
        var interceptor: Interceptor?
        var adapter: TokenAdapter?
        
        if let setToken = setToken {
            adapter = TokenAdapter(setToken: setToken)
            interceptor = Interceptor(adapter: adapter!)
        }
        
        let session = AFSessionManager(configuration: URLSessionConfiguration.default, interceptor: interceptor)
        return session
    }
}
