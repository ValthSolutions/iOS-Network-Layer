import Foundation

public enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

// MARK: - RequestProvider

   /// Creates a `RequestProvider` to retrieve the contents of the specified `url`, `method`, `path`, `query`
   /// , `body` and `headers`.
   ///
   /// - parameter url:        The URL.
   /// - parameter method:     The HTTPMethod enum.
   /// - parameter path:       The RequestPathConvertible adds in the end of URL. Use next format `/user/1` or `[/user, 1]`
   /// - parameter query: The queryItems adds in the URL after `?` all items separate by `&` `?search&name=Artur&age=27`.
   /// - parameter headers:    The HTTP headers.
   /// - parameter body:       The RequestBodyConvertible. By encode parameters to `httpBody`.

public protocol URLComposer {
    
    func compose(into url: URL) throws -> URL
}

public protocol RequestComposer {

    func compose(into request: URLRequest) throws -> URLRequest
}

public protocol RequestProvider {
    
    var method: HTTPMethod { get }
    
    var url: String { get }
    
    var path: URLComposer { get }
    var query: URLComposer { get }
    
    var headers: RequestComposer { get }
    var body: RequestComposer { get }
    
    func asURL() throws -> URL
    
    func asURLRequest() throws -> URLRequest
}

public extension RequestProvider {
    
    public func asURL() throws -> URL {
        guard var url = URL(string: self.url) else {
            throw RepositoryError.invalidStringURL(string: self.url)
        }
        
        url = try path.compose(into: url)
        url = try query.compose(into: url)
        
        return url
    }
    
    public func asURLRequest() throws -> URLRequest {
        var url = try self.asURL()
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = method.rawValue
        urlRequest = try body.compose(into: urlRequest)
        urlRequest = try headers.compose(into: urlRequest)

        return urlRequest
    }
}

public extension String {
    
    func escape() -> String {
        addingPercentEncoding(withAllowedCharacters: .URLQueryAllowed) ?? ""
    }
}

public extension CharacterSet {
    /// Creates a CharacterSet from RFC 3986 allowed characters.
    ///
    /// RFC 3986 states that the following characters are "reserved" characters.
    ///
    /// - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
    /// - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ";", "="
    ///
    /// In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
    /// query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
    /// should be percent-escaped in the query string.
    static let URLQueryAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+;="
        let encodableDelimiters = CharacterSet(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

        return CharacterSet.urlQueryAllowed.subtracting(encodableDelimiters)
    }()
}
