import Alamofire
import Foundation
import NetworkInterface

public struct DEBUGLog: Log {
    
    private let separator = " "
    private let empty = "----"
    
    public init() {}
    
    public func log<T>(_ response: AFDataResponse<T?>,
                       _ config: Requestable? = nil) {
        divider()
        methodName(response.request?.httpMethod)
        urlPath(response.request?.url?.absoluteString)
        parameters(config?.queryParameters)
        header(response.request?.allHTTPHeaderFields)
        statusCode(response.response?.statusCode)
        metrics(response.metrics)
        jsonResponse(response.data)
    }
    
    public func log<T, E>(_ response: DataResponse<T, E>,
                          _ config: Requestable? = nil) {
        divider()
        methodName(response.request?.httpMethod)
        urlPath(response.request?.url?.absoluteString)
        parameters(config?.queryParameters)
        header(response.request?.allHTTPHeaderFields)
        statusCode(response.response?.statusCode)
        metrics(response.metrics)
        jsonResponse(response.data)
    }
    
    public func log(_ response:  DownloadResponsePublisher<Data>.Output,
                    _ config: Requestable? = nil) {
        divider()
        methodName(response.request?.httpMethod)
        urlPath(response.request?.url?.absoluteString)
        parameters(config?.queryParameters)
        header(response.request?.allHTTPHeaderFields)
        statusCode(response.response?.statusCode)
        metrics(response.metrics)
        jsonResponse(response.value)
    }
    
    public func success<T>(_ value: T) {
        print("📗 Success:", value, separator: separator, terminator: "\n\n")
        divider()
    }
    
    public func failure(_ error: Error) {
        print("📕 Failure:", error, separator: separator, terminator: "\n\n")
        divider()
    }
    
    private func divider(_ symols: Int = 60) {
        print((0 ... symols).compactMap { _ in return "-" }.reduce("", { divider, add -> String in
            return divider + add
        }))
    }
    
    fileprivate func methodName(_ name: String?) {
        if let name = name {
            print("📘 Method:", name, separator: separator)
        } else {
            print("📓 Method:", empty, separator: separator)
        }
    }
    
    fileprivate func urlPath(_ path: String?) {
        if let path = path {
            print("📘 URL:", path, separator: separator)
        } else {
            print("📓 URL:", empty, separator: separator)
        }
    }
    
    fileprivate func header(_ header: [String: String]?) {
        if let header = header, header.isEmpty == false {
            let string = header.compactMap {
                "[\($0): \($1)]"
            }.joined(separator: "\n           ")
            print("📘 Header:", string, separator: separator)
        } else {
            print("📓 Header:", empty, separator: separator)
        }
    }
    
    fileprivate func parameters(_ parameters: [String: Any]?) {
        if let parameters = parameters, parameters.isEmpty == false {
            let string = parameters.compactMap {
                "[\($0): \($1)]"
            }.joined(separator: "\n           ")
            print("📘 Parameters:", string, separator: separator)
        } else {
            print("📓 Parameters:", empty, separator: separator)
        }
    }
    
    fileprivate func statusCode(_ code: NSInteger?) {
        if let code = code {
            switch code {
            case 200..<300:
                print("📗 StatusCode:", code, separator: separator)
                
            case 300..<500:
                print("📕 StatusCode:", code, separator: separator)
                
            default:
                print("📙 StatusCode:", code, separator: separator)
            }
        } else {
            print("📙 StatusCode:", empty, separator: separator)
        }
    }
    
    fileprivate func metrics(_ metrics: URLSessionTaskMetrics?) {
        if let duration = metrics?.taskInterval.duration {
            switch duration {
            case 0..<1:
                print("📗 Duration:", duration, separator: separator)
            case 1..<3:
                print("📙 Duration:", duration, separator: separator)
            default:
                print("📕 Duration:", duration, separator: separator)
            }
        } else {
            print("📙 Duration:", empty, separator: separator)
        }
    }
    
    fileprivate func jsonResponse(_ data: Data?) {
        if let json = data.flatMap { $0.prettyPrintedJSONString } {
            print("📓 JSON:", json)
        } else {
            print("📓 JSON:", empty)
        }
    }
}
extension Data {
    
    var prettyPrintedJSONString: NSString? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        
        return prettyPrintedString
    }
}
