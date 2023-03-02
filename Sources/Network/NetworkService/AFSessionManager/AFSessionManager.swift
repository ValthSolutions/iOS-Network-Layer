
import Alamofire
import Foundation
import NetworkInterface

public class AFSessionManager: Session {
    
    public static func `default`(setToken: ((inout [String: String]) -> Void)?) -> AFSessionManager {
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
