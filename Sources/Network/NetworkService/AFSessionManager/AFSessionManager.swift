
import Alamofire
import Foundation
import NetworkInterface


//MARK: - initialization
/*
 let session = AFSessionManager.default { token in
     token["bearer"] = "1jbdi1df"
 }

 */

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



public protocol NetworkConfigurable {
  var baseURL: URL { get }
  var headers: [String: String] { get }
  var queryParameters: [String: String] { get }
}


public struct ApiDataNetworkConfig: NetworkConfigurable {

  public let baseURL: URL

  public let headers: [String: String]

  public let queryParameters: [String: String]

  public init(baseURL: URL,
              headers: [String: String] = [:],
              queryParameters: [String: String] = [:]) {
    self.baseURL = baseURL
    self.headers = headers
    self.queryParameters = queryParameters
      
  }
}