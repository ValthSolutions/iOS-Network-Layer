import Alamofire
import Foundation

public enum LogLevel {
    case debug
    case release
}

public protocol Loger {
    func log<T, E>(_ response: DataResponse<T, E>, _ config: Requestable?)
    func log(_ response: DownloadResponsePublisher<Data>.Output, _ config: Requestable?)
    func logStreamChunk(_ result: Result<Data, Never>)
    func logStreamCompletion(_ completion: DataStreamRequest.Completion)
    func logRequestInitiation(_ request: URLRequest?)
    func success<T>(_ value: T)
    func failure(_ error: Error)
}
