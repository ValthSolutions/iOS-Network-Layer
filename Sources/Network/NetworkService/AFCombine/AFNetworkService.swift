import Alamofire
import Foundation

open class AFNetworkService {
 
    public var handler: BaseHandler
    public var session: Alamofire.Session
    
    public init(session: Alamofire.Session, handler: BaseHandler) {
        self.session = session
        self.handler = handler
    }
}
