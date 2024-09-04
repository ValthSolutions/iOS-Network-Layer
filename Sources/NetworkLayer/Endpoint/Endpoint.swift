import Foundation
import INetwork
import Alamofire

public final class Endpoint<R>: ResponseRequestable {
    public typealias Response = R
    
    public var path: String
    public var isFullPath: Bool
    public var method: HTTPMethodType
    public var headerParameters: [String: String]
    public var queryParametersEncodable: Encodable?
    public var queryParameters: [String: Any]
    public var bodyParametersEncodable: Encodable?
    public var bodyArrayEncodable: [AnyEncodable]?
    public var bodyParameters: [String: Any]
    public var bodyEncoding: BodyEncoding
    
    public init(path: String,
                isFullPath: Bool = false,
                method: HTTPMethodType,
                headerParameters: [String: String] = [:],
                queryParametersEncodable: Encodable? = nil,
                queryParameters: [String: Any] = [:],
                bodyParametersEncodable: Encodable? = nil,
                bodyArrayEncodable: [AnyEncodable]? = nil,
                bodyParameters: [String: Any] = [:],
                bodyEncoding: BodyEncoding = .jsonSerializationData) {
        self.path = path
        self.isFullPath = isFullPath
        self.method = method
        self.headerParameters = headerParameters
        self.queryParametersEncodable = queryParametersEncodable
        self.queryParameters = queryParameters
        self.bodyParametersEncodable = bodyParametersEncodable
        self.bodyParameters = bodyParameters
        self.bodyArrayEncodable = bodyArrayEncodable
        self.bodyEncoding = bodyEncoding
    }
}

extension Requestable {
    
    public func asURLRequest(config: NetworkConfigurable, encoder: JSONEncoder) throws -> URLRequest {
        let url = try self.url(with: config, encoder: encoder)
        
        var urlRequest = URLRequest(url: url)
        var allHeaders: [String: String] = config.headers
        headerParameters.forEach { allHeaders.updateValue($1, forKey: $0) }
        
        let bodyParameters = try bodyParametersEncodable?.toDictionary(encoder: encoder) ?? self.bodyParameters
        
        if let bodyArray = bodyArrayEncodable {
            let jsonEncoder = JSONEncoder()
            urlRequest.httpBody = try jsonEncoder.encode(bodyArray)
        }
        
        if !bodyParameters.isEmpty {
            urlRequest.httpBody = encodeBody(bodyParamaters: bodyParameters, bodyEncoding: bodyEncoding)
        }
        
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = allHeaders
        
        return urlRequest
    }
    
    private func url(with config: NetworkConfigurable, encoder: JSONEncoder) throws -> URL {
        let baseURL = config.baseURL.absoluteString.last != "/" ? config.baseURL.absoluteString + "/" : config.baseURL.absoluteString
        let endpoint = isFullPath ? path : baseURL.appending(path)
        
        guard var urlComponents = URLComponents(string: endpoint) else { throw RequestGenerationError.components }
        var urlQueryItems = [URLQueryItem]()
        
        let queryParameters = try queryParametersEncodable?.toDictionary(encoder: encoder) ?? self.queryParameters
        
        queryParameters.forEach {
            urlQueryItems.append(URLQueryItem(name: $0.key, value: "\($0.value)"))
        }
        
        config.queryParameters.forEach {
            urlQueryItems.append(URLQueryItem(name: $0.key, value: $0.value))
        }
        
        urlComponents.queryItems = !urlQueryItems.isEmpty ? urlQueryItems : nil
        guard let url = urlComponents.url else { throw RequestGenerationError.components }
        
        return url
    }
    
    private func encodeBody(bodyParamaters: [String: Any], bodyEncoding: BodyEncoding) -> Data? {
        switch bodyEncoding {
        case .jsonSerializationData:
            return try? JSONSerialization.data(withJSONObject: bodyParamaters)
        case .stringEncodingAscii:
            return bodyParamaters.queryString.data(using: String.Encoding.ascii, allowLossyConversion: true)
        }
    }
}
