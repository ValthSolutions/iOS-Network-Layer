import Alamofire
import Foundation
import Combine
import Alamofire


open class BaseHandler {
    
    private let loger: Log
    
    public init(_ loger: Log) {
        self.loger = loger
    }
    
    open func handle<T>(_ response: AFDataResponse<T>) -> Result<T, Error> {
        loger.log(response)
        
        switch response.result {
        case .success(let value):
            loger.success(value)
            return responseSuccess(response, item: value)
            
        case .failure(let error):
            loger.failure(error)
            return responseError(response, error: error)
        }
    }
    
    open func responseSuccess<T>(_ response: AFDataResponse<T>, item: T) -> Result<T, Error> {
        .success(item)
    }
    
    open func responseError<T>(_ response: AFDataResponse<T>, error: Error) -> Result<T, Error> {
        .failure(error)
    }
}


open class CombineHandler {
    
    private var logger: RLog
    
    public init(_ loger: RLog) {
        self.logger = loger
    }
    
    open func handle<T>(_ publisher: DataResponsePublisher<T>, item: T) {
        logger.log(publisher)
    }
    
    open func responseSuccess<T>(_ publisher: DataResponsePublisher<T>, item: T) -> Result<T, Error> {
        .success(item)
    }
    
    open func responseError<T>(_ publisher: DataResponsePublisher<T>, error: Error) -> Result<T, Error> {
        .failure(error)
    }
}
//p { value -> Result<T, Error> in
//    self.responseSuccess(publisher, item: item)
//}
//.mapError { error -> Result<T, Error> in
//    self.responseError(publisher, error: error)
//}
//.sink(receiveCompletion: { _ in }, receiveValue: { _ in })
//.store(in: &logger.bag)
