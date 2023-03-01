import Alamofire
import Foundation
import Combine

public protocol RLog {
    func log<T>(_ publisher: DataResponsePublisher<T>)
    func success<T>(_ value: T)
    func failure(_ error: Error)
    
    var bag: Set<AnyCancellable> { get set }
}

public class RDEBUGLog: RLog {
    let separator = " "
    let empty = "----"
    public var bag = Set<AnyCancellable>()

    public init() {}
    
    public func log<Value>(_ publisher: DataResponsePublisher<Value>) {
        publisher.sink(receiveCompletion: { [unowned self] completion in
            switch completion {
            case .failure(let error):
                self.failure(error)
            case .finished:
                break
            }
        }, receiveValue: { [unowned self] value in
            self.success(value)
                        
            guard let response = value.response,
                  let request = value.request else {
                return
            }

            self.methodName(request.httpMethod)
            self.urlPath(request.url?.absoluteString)
            self.header(request.allHTTPHeaderFields)
            self.parameters(request.httpBody)
            self.statusCode(response.statusCode)
            self.metrics(value.metrics)
            self.jsonResponse(value.data)
        })
        .store(in: &bag)
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
                "\($0): \($1)"
            }.joined(separator: "\n           ")
            
            print("📘 Header:", string, separator: separator)
        } else {
            print("📓 Header:", empty, separator: separator)
        }
    }
    
    fileprivate func parameters(_ data: Data?) {
        if let parameters = data.flatMap { $0.prettyPrintedJSONString } {
            print("📘 Parameters:", parameters, separator: separator)
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
